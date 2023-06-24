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
    if #entityrefs == 1 then
        return GetMutableEntityFromAll(entityrefs[1])
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
        if IsProtectedDescriptor(entityColumn.descriptor) then
            SetProtectedField(entity, entityColumn.descriptor, entityColumn.description)
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

local function formatHistoryItemForC(item)
    local newItem = {}

    newItem.label = GetProtectedStringField(item, "label")

    newItem.content = GetProtectedStringField(item, "content")

    local is_concerns_others = GetProtectedNullableField(item, "isConcernsOthers")
    if not is_concerns_others then is_concerns_others = false end
    newItem.is_concerns_others = is_concerns_others

    local is_secret = GetProtectedNullableField(item, "isSecret")
    if not is_secret then is_secret = false end
    newItem.is_secret = is_secret

    local year = GetProtectedNullableField(item, "year")
    if not year then
        LogError("History item " .. newItem.label .. " has no year.")
        return {}
    end
    newItem.year = year

    local day = GetProtectedNullableField(item, "day")
    if not day then day = 0 end
    newItem.day = day

    local originator = GetProtectedNullableField(item, "originator")
    newItem.originator = optionalEntityToString(originator)

    local yearFormat = GetProtectedNullableField(item, "yearFormat")
    newItem.year_format = optionalEntityToString(yearFormat)
    return item
end

function GetHistoryItemColumns()
    local historyItems = {}
    for _, item in pairs(AllHistoryItems) do
        local newItem = formatHistoryItemForC(item)
        table.insert(historyItems, newItem)
    end
    return historyItems
end

function HistoryItemsFromColumns(historyItemColumns)
    for _, item in pairs(historyItemColumns) do
        table.insert(AllHistoryItems, item)
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
            if not role then role = "" end
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
        if not role then role = "" end
        AddParent { entity = child, parentLabel = parentLabel, relationship = role }
    end
end
