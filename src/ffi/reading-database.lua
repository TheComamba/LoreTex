local function getNumberOfEntityColumns(dbPath)
    local ffi = getFFIModule()
    local loreCore = getLib()
    if not ffi or not loreCore then return nil end

    local numEntityColumns = ffi.new("intptr_t[1]")
    local result = loreCore.get_number_of_entity_columns(dbPath, numEntityColumns)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
        return nil
    end

    return numEntityColumns
end

local function readEntityColumns(dbPath)
    local ffi = getFFIModule()
    local loreCore = getLib()
    if not ffi or not loreCore then return {} end

    local numEntityColumns = getNumberOfEntityColumns(dbPath)
    if not numEntityColumns then return {} end

    local cEntityColumns = ffi.new("CEntityColumn[?]", ffi.number(numEntityColumns[0]))

    local result = loreCore.read_entity_columns(dbPath, cEntityColumns)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
        return {}
    end

    local entityColumns = {}
    for i = 0, (ffi.number(numEntityColumns[0]) - 1) do
        local cEntityColumn = cEntityColumns[i]
        local entityColumn = {}
        entityColumn.label = ffi.string(cEntityColumn.label)
        entityColumn.descriptor = ffi.string(cEntityColumn.descriptor)
        entityColumn.description = ffi.string(cEntityColumn.description)
        tex.print(i)
        tex.print(DebugPrint(entityColumn) .. [[ endline\\]])
        table.insert(entityColumns, entityColumn)
    end
    return entityColumns
end

local function readEntities(dbPath)
    local entityColumns = readEntityColumns(dbPath)
    for _, entityColumn in pairs(entityColumns) do
        local entity = GetMutableEntityFromAll(entityColumn.label)
        SetDescriptor { entity = entity, descriptor = entityColumn.descriptor, description = entityColumn.description }
    end
end

TexApi.readLoreFromDatabase = function(dbPath)
    getLib() --Load the library if it hasn't been loaded yet.
    readEntities(dbPath)
end
