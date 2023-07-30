local entityRefCommand = "entityref"

local descriptionToString

local function optionalEntityToString(inp)
    if IsEntity(inp) then
        local label = GetProtectedStringField(inp, "label")
        return TexCmd(entityRefCommand, label)
    else
        return ""
    end
end

descriptionToString = function(description)
    if IsEntity(description) then
        return optionalEntityToString(description)
    elseif type(description) == "table" then
        require("lualibs.lua")
        return utilities.json.tostring(description)
    else
        return tostring(description)
    end
end

local function shouldDescriptorBeWrittenToDatabase(descriptor)
    if descriptor == GetProtectedDescriptor("historyItems") then
        return false
    elseif descriptor == GetProtectedDescriptor("children") then
        return false
    elseif descriptor == GetProtectedDescriptor("parents") then
        return false
    elseif descriptor == GetProtectedDescriptor("label") then
        return false
    elseif descriptor == GetProtectedDescriptor("mentions") then
        return false
    else
        return true
    end
end

local function createEntityColumn(label, descriptor, description)
    local ffi = GetFFIModule()
    if not ffi then return nil end

    if not shouldDescriptorBeWrittenToDatabase(descriptor) then
        return nil
    end

    local column = {};
    column.label = label
    column.descriptor = descriptor
    column.description = descriptionToString(description)

    return column
end

local function isEntityRef(descriptionString)
    local entityrefs = ScanStringForCmd(descriptionString, entityRefCommand)
    if #entityrefs == 0 then
        return false
    elseif #entityrefs == 1 then
        return true
    else
        LogError("Multiple entity references in description string: " .. descriptionString)
        return false
    end
end

local function isTableString(descriptionString)
    local strippedString = string.gsub(descriptionString, "%s+", "")
    if string.sub(strippedString, 1, 1) == "{" then
        return true
    elseif string.sub(strippedString, 1, 1) == "[" then
        return true
    else
        return false
    end
end

local function isNumberString(descriptionString)
    local num = tonumber(descriptionString)
    if num then
        return true
    else
        return false
    end
end

local function stringToBoolean(descriptionString)
    if descriptionString:lower() == "true" then
        return true
    elseif descriptionString:lower() == "false" then
        return false
    else
        return nil
    end
end

local function stringToDescription(descriptionString)
    if isEntityRef(descriptionString) then
        local entityrefs = ScanStringForCmd(descriptionString, entityRefCommand)
        return GetMutableEntityFromAll(entityrefs[1])
    elseif isTableString(descriptionString) then
        require("lualibs.lua")
        return utilities.json.tolua(descriptionString)
    elseif isNumberString(descriptionString) then
        return tonumber(descriptionString)
    elseif stringToBoolean(descriptionString) ~= nil then
        return stringToBoolean(descriptionString)
    else
        return descriptionString
    end
end

function GetEntityColumns()
    local entityColumns = {}
    for _, entity in pairs(AllEntities) do
        local label = GetProtectedStringField(entity, "label")
        for descriptor, description in pairs(entity) do
            local column = createEntityColumn(label, descriptor, description)
            if column then
                table.insert(entityColumns, column)
            end
        end
    end
    return entityColumns
end

function EntitiesFromColumns(entityColumns)
    for _, entityColumn in pairs(entityColumns) do
        local entity = GetMutableEntityFromAll(entityColumn.label)
        entityColumn.description = stringToDescription(entityColumn.description)
        if IsProtectedDescriptor(entityColumn.descriptor) then
            SetProtectedField(entity, entityColumn.descriptor, entityColumn.description)
            if entityColumn.descriptor == GetProtectedDescriptor("category") then
                AddCategory(entityColumn.description)
            end
        elseif IsEntity(entityColumn.description) then
            entity[entityColumn.descriptor] = entityColumn.description
        else
            local args = {};
            args.entity = entity
            args.descriptor = entityColumn.descriptor
            args.description = entityColumn.description
            SetDescriptor(args)
        end
    end
end

local function boolToNumber(bool)
    if bool then
        return 1
    else
        return 0
    end
end

local function formatHistoryItemForC(luaItem)
    local cItem = {}

    cItem.label = GetProtectedStringField(luaItem, "label")

    cItem.content = GetProtectedStringField(luaItem, "content")

    local isConcernsOthers = GetProtectedNullableField(luaItem, "isConcernsOthers")
    cItem.is_concerns_others = boolToNumber(isConcernsOthers)

    local isSecret = GetProtectedNullableField(luaItem, "isSecret")
    cItem.is_secret = boolToNumber(isSecret)

    local year = GetProtectedNullableField(luaItem, "year")
    if not year then
        LogError("History item " .. cItem.label .. " has no year.")
        return {}
    end
    cItem.year = year

    local day = GetProtectedNullableField(luaItem, "day")
    if not day then day = 0 end
    cItem.day = day

    local originator = GetProtectedNullableField(luaItem, "originator")
    cItem.originator = optionalEntityToString(originator)
    return cItem
end

function GetHistoryItemColumns()
    local historyItems = {}
    for _, item in pairs(AllHistoryItems) do
        local newItem = formatHistoryItemForC(item)
        table.insert(historyItems, newItem)
    end
    return historyItems
end

local function formatCHistoryItemForLua(cItem)
    local luaItem = {}
    luaItem.label = cItem.label
    luaItem.event = cItem.content
    local isConcernsOthers = cItem.is_concerns_others ~= 0
    luaItem.isConcernsOthers = isConcernsOthers
    local isSecret = cItem.is_secret ~= 0
    luaItem.isSecret = isSecret
    luaItem.year = cItem.year
    if cItem.day ~= 0 then
        luaItem.day = cItem.day
    end
    luaItem.originator = stringToDescription(cItem.originator)
    return luaItem
end

function HistoryItemsFromColumns(historyItemColumns)
    for _, item in pairs(historyItemColumns) do
        item = formatCHistoryItemForLua(item)
        AddHistory(item)
    end
end

function GetRelationshipColumns()
    local relationships = {}
    for _, entity in pairs(AllEntities) do
        local parentsAndRoles = GetProtectedTableReferenceField(entity, "parents", false)
        local childlabel = GetProtectedStringField(entity, "label")
        for _, parentAndRole in pairs(parentsAndRoles) do
            local parent = parentAndRole[1]
            local role = parentAndRole[2]
            if role == nil then role = "" end
            local parentLabel = GetProtectedStringField(parent, "label")
            local relationship = {}
            relationship.parent = parentLabel
            relationship.child = childlabel
            relationship.role = role
            table.insert(relationships, relationship)
        end
    end
    return relationships
end

function RelationshipsFromColumns(relationshipColumns)
    for _, relationship in pairs(relationshipColumns) do
        local parentLabel = relationship.parent
        local child = GetMutableEntityFromAll(relationship.child)
        local role
        if relationship.role ~= "" then
            role = relationship.role
        end
        AddParent { entity = child, parentLabel = parentLabel, relationship = role }
    end
end
