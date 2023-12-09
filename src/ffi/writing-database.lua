local function toCColumns(luaColumns, ccategory)
    if not type(luaColumns) == "table" then
        LogError("Function toCColumns expected table, got " .. type(luaColumns))
        return nil
    end
    if not type(ccategory) == "string" then
        LogError("Function toCColumns expected string, got " .. type(ccategory))
        return nil
    end
    local ffi = GetFFIModule()
    if not ffi then return nil end

    local cColumns = ffi.new(ccategory .. "[" .. #luaColumns .. "]")
    for i = 0, (#luaColumns - 1) do
        local luaColumn = luaColumns[i + 1]
        if not type(luaColumn) == "table" then
            LogError("Function toCColumns expected entry " .. (i + 1) ..
                " to be a table, but it is a " .. type(luaColumn))
            return nil
        end
        for key, value in pairs(luaColumn) do
            if not value then
                LogError("Function toCColumns expected entry " ..
                    (i + 1) .. " to be a table with no nil values, but " .. key .. " is nil")
                return nil
            end
        end
        cColumns[i] = luaColumn
    end
    return cColumns, #luaColumns
end

local function writeToDatabase(dbPath, columns, ccategory, writeFunction)
    local ffi = GetFFIModule()
    if not ffi then return nil end

    local cColumns, count = toCColumns(columns, ccategory)
    if not cColumns then return nil end
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

function CurrentTimestamp()
    local ffi = GetFFIModule()
    if not ffi then return nil end

    local loreCore = GetLib()
    if not loreCore then return nil end

    return loreCore.get_current_timestamp()
end