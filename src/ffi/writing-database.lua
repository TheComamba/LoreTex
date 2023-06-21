local function optionalEntityToString(inp)
    if IsEntity(inp) then
        local label = GetProtectedStringField(inp, "label")
        return [[ENTITY{]] .. label .. [[}]]
    else
        return ""
    end
end

local descriptionToString

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

local function getEntityColumns()
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

local function toCColumns(columns, cTypename)
    if not type(columns) == "table" then
        return nil
    end
    if not type(cTypename) == "string" then
        return nil
    end
    local ffi = GetFFIModule()
    if not ffi then return nil end

    local cColumns = ffi.new(cTypename .. "[" .. #columns .. "]")
    for i = 0, (#columns - 1) do
        cColumns[i] = columns[i + 1]
    end
    return cColumns, #columns
end

local function writeEntitiesToDatabase(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not loreCore or not ffi then return nil end

    local cEntityColumns, count = toCColumns(getEntityColumns(), "CEntityColumn")
    local result = loreCore.write_entity_columns(dbPath, cEntityColumns, count)

    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

local function getHistoryItems()
    local historyItems = {}
    for i, item in pairs(historyItems) do
        historyItems[i].label = GetProtectedStringField(item, "label")
        historyItems[i].content = GetProtectedStringField(item, "content")
        historyItems[i].is_concerns_others = GetProtectedNullableField(item, "isConcernsOthers")
        historyItems[i].is_secret = GetProtectedNullableField(item, "isSecret")
        historyItems[i].year = GetProtectedNullableField(item, "year")
        historyItems[i].day = GetProtectedNullableField(item, "day")
        local originator = GetProtectedNullableField(item, "originator")
        historyItems[i].originator = optionalEntityToString(originator)
        local yearFormat = GetProtectedNullableField(item, "yearFormat")
        historyItems[i].year_format = optionalEntityToString(yearFormat)
    end
    return historyItems
end

local function writeHistoryItemsToDatabase(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not loreCore or not ffi then return nil end

    local items, count = toCColumns(getHistoryItems(), "CHistoryItem")
    local result = loreCore.write_history_items(dbPath, items, count)

    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

local function getRelationships()
    local relationships = {}
    for _, entity in pairs(AllEntities) do
        local parentsAndRoles = GetProtectedTableReferenceField(entity, "parents")
        local childlabel = GetProtectedStringField(entity, "label")
        for _, parentAndRole in pairs(parentsAndRoles) do
            local parent = parentAndRole[1]
            local role = parentAndRole[2]
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

local function writeRelationshipsToDatabase(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not loreCore or not ffi then return nil end

    local cRelationships, count = toCColumns(getRelationships(), "CEntityRelationship")
    local result = loreCore.write_relationships(dbPath, cRelationships, count)

    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

TexApi.writeLoreToDatabase = function(dbPath)
    GetLib() --Load the library if it hasn't been loaded yet.
    writeEntitiesToDatabase(dbPath)
    writeHistoryItemsToDatabase(dbPath)
    writeRelationshipsToDatabase(dbPath)
end
