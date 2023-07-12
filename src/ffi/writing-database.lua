local function toCColumns(luaColumns, ccategory)
    if not type(luaColumns) == "table" then
        return nil
    end
    if not type(ccategory) == "string" then
        return nil
    end
    local ffi = GetFFIModule()
    if not ffi then return nil end

    local cColumns = ffi.new(ccategory .. "[" .. #luaColumns .. "]")
    for i = 0, (#luaColumns - 1) do
        cColumns[i] = luaColumns[i + 1]
    end
    return cColumns, #luaColumns
end

local function writeToDatabase(dbPath, columns, ccategory, writeFunction)
    local ffi = GetFFIModule()
    if not ffi then return nil end

    local cColumns, count = toCColumns(columns, ccategory)
    local result = writeFunction(dbPath, cColumns, count)

    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

TexApi.writeLoreToDatabase = function(dbPath)
    local loreCore = GetLib()
    if not loreCore then return nil end
    writeToDatabase(dbPath, GetEntityColumns(), "CEntityColumn", loreCore.write_entity_columns)
    writeToDatabase(dbPath, GetHistoryItemColumns(), "CHistoryItem", loreCore.write_history_items)
    writeToDatabase(dbPath, GetRelationshipColumns(), "CEntityRelationship", loreCore.write_relationships)
end
