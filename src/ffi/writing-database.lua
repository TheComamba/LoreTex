local function optionalEntityToString(inp)
    if IsEntity(inp) then
        local label = GetProtectedStringField(inp, "label")
        return TexCmd(EntityRefCommand, label)
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

local function toCColumns(luaColumns, cTypename)
    if not type(luaColumns) == "table" then
        return nil
    end
    if not type(cTypename) == "string" then
        return nil
    end
    local ffi = GetFFIModule()
    if not ffi then return nil end

    local cColumns = ffi.new(cTypename .. "[" .. #luaColumns .. "]")
    for i = 0, (#luaColumns - 1) do
        cColumns[i] = luaColumns[i + 1]
    end
    return cColumns, #luaColumns
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

local function getHistoryItems()
    local historyItems = {}
    for _, item in pairs(historyItems) do
        local newItem = formatHistoryItemForC(item)
        if #newItem ~= 0 then
            table.insert(historyItems, newItem)
        end
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
