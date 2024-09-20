local entityRefCommand = "entityref"

local toProperLuaObject

local function optionalEntityToString(inp)
    if IsEntity(inp) then
        local label = GetProtectedStringField(inp, "label")
        return TexCmd(entityRefCommand, label)
    else
        return ""
    end
end

local function entitiesToRefs(input)
    if IsEntity(input) then
        return optionalEntityToString(input)
    elseif type(input) == "table" then
        local out = {}
        for key, val in pairs(input) do
            out[key] = entitiesToRefs(val)
        end
        return out
    else
        return input
    end
end

local function toDatabaseString(input)
    input = entitiesToRefs(input)
    if type(input) == "table" then
        require("lualibs.lua")
        return utilities.json.tostring(input)
    else
        return tostring(input)
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
    column.description = toDatabaseString(description)

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

local function stringToProperLuaObject(descriptionString)
    if isTableString(descriptionString) then
        require("lualibs.lua")
        local tmp = utilities.json.tolua(descriptionString)
        local out = {}
        for key, val in pairs(tmp) do
            out[key] = toProperLuaObject(val)
        end
        return out
    elseif isNumberString(descriptionString) then
        return tonumber(descriptionString)
    elseif stringToBoolean(descriptionString) ~= nil then
        return stringToBoolean(descriptionString)
    elseif isEntityRef(descriptionString) then
        local entityrefs = ScanStringForCmd(descriptionString, entityRefCommand)
        return GetMutableEntityFromAll(entityrefs[1])
    else
        return descriptionString
    end
end

toProperLuaObject = function(input)
    if type(input) == "string" then
        return stringToProperLuaObject(input)
    elseif type(input) == "table" and not IsEntity(input) then
        local out = {}
        for key, val in pairs(input) do
            out[key] = toProperLuaObject(val)
        end
        return out
    else
        return input
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
        entityColumn.description = toProperLuaObject(entityColumn.description)
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

local function formatHistoryItemForC(luaItem)
    local cItem = {}

    local timestamp = GetProtectedNullableField(luaItem, "timestamp")
    if not timestamp then
        LogError("History item has no timestamp:" .. DebugPrint(luaItem))
        return {}
    end
    cItem.timestamp = timestamp

    local year = GetProtectedNullableField(luaItem, "year")
    if not year then
        LogError("History item has no year:" .. DebugPrint(luaItem))
        return {}
    end
    cItem.year = year

    local day = GetProtectedNullableField(luaItem, "day")
    if not day then day = 0 end
    cItem.day = day

    cItem.content = GetProtectedStringField(luaItem, "content")

    local properties = GetProtectedTableReferenceField(luaItem, "properties")
    cItem.properties = toDatabaseString(properties)

    return cItem
end

local function isGenerated(item)
    local properties = GetProtectedTableReferenceField(item, "properties")
    return GetProtectedNullableField(properties, "isGenerated")
end

function GetHistoryItemColumns()
    local historyItems = {}
    for _, item in pairs(AllHistoryItems) do
        if not isGenerated(item) then
            local newItem = formatHistoryItemForC(item)
            table.insert(historyItems, newItem)
        end
    end
    return historyItems
end

local function formatCHistoryItemForLua(cItem)
    local luaItem = {}
    SetProtectedField(luaItem, "timestamp", cItem.timestamp)
    SetProtectedField(luaItem, "year", cItem.year)
    if cItem.day ~= 0 then
        SetProtectedField(luaItem, "day", cItem.day)
    end
    SetProtectedField(luaItem, "content", cItem.content)
    SetProtectedField(luaItem, "properties", toProperLuaObject(cItem.properties))
    return luaItem
end

function HistoryItemsFromColumns(historyItemColumns)
    for _, item in pairs(historyItemColumns) do
        item = formatCHistoryItemForLua(item)
        ProcessHistoryItem(item)
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
