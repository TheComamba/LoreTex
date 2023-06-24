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

local function listToString(list)
    local out = {}
    for i = 1, #list do
        Append(out, descriptionToString(list[i]))
    end
    return [[{]] .. table.concat(out, ", ") .. [[}]]
end

descriptionToString = function(description)
    if IsEntity(description) then
        return optionalEntityToString(description)
    elseif type(description) == "table" then
        return listToString(description)
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


local function stringToDescription(descriptionString)
    local entityrefs = ScanStringForCmd(descriptionString, entityRefCommand)
    if #entityrefs == 0 then
        return descriptionString
    elseif #entityrefs == 1 then
        return GetMutableEntityFromAll(entityrefs[1])
    else
        LogError("Multiple entity references in description string: " .. descriptionString)
        return nil
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
        if IsProtectedDescriptor(entityColumn.descriptor) then
            local description = stringToDescription(entityColumn.description)
            SetProtectedField(entity, entityColumn.descriptor, description)
        else
            local args = {};
            args.entity = entity
            args.descriptor = entityColumn.descriptor
            args.description = stringToDescription(entityColumn.description)
            args.suppressDerivedDescriptors = true
            SetDescriptor(args)
        end
    end
end

local function formatHistoryItemForC(luaItem)
    local cItem = {}

    cItem.label = GetProtectedStringField(luaItem, "label")

    cItem.content = GetProtectedStringField(luaItem, "content")

    local is_concerns_others = GetProtectedNullableField(luaItem, "isConcernsOthers")
    if not is_concerns_others then is_concerns_others = false end
    cItem.is_concerns_others = is_concerns_others

    local is_secret = GetProtectedNullableField(luaItem, "isSecret")
    if not is_secret then is_secret = false end
    cItem.is_secret = is_secret

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

    local yearFormat = GetProtectedNullableField(luaItem, "yearFormat")
    cItem.year_format = optionalEntityToString(yearFormat)
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
    luaItem.event = cItem.content
    luaItem.isConcernsOthers = cItem.is_concerns_others
    luaItem.isSecret = cItem.is_secret
    luaItem.year = cItem.year
    luaItem.day = cItem.day
    luaItem.label = cItem.label
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
            if role == "" then role = nil end
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
        local role = relationship.role
        AddParent { entity = child, parentLabel = parentLabel, relationship = role }
    end
end