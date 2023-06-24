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

    local cEntityColumns, count = toCColumns(GetEntityColumns(), "CEntityColumn")
    local result = loreCore.write_entity_columns(dbPath, cEntityColumns, count)

    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

local function writeHistoryItemsToDatabase(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not loreCore or not ffi then return nil end

    local items, count = toCColumns(GetHistoryItemColumns(), "CHistoryItem")
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
