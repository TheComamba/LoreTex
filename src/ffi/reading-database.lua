local function getNumberOfEntityColumns(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
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
    local ffi = GetFFIModule()
    local loreCore = GetLib()
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
        table.insert(entityColumns, entityColumn)
    end
    return entityColumns
end

local function readEntities(dbPath)
    local entityColumns = readEntityColumns(dbPath)
    for _, entityColumn in pairs(entityColumns) do
        local entity = GetMutableEntityFromAll(entityColumn.label)
        if IsProtectedDescriptor(entityColumn.descriptor) then
            SetProtectedField(entity, entityColumn.descriptor, entityColumn.description)
        else
            local args = {};
            args.entity = entity
            args.descriptor = entityColumn.descriptor
            args.description = entityColumn.description
            args.suppressDerivedDescriptors = true
            SetDescriptor(args)
        end
    end
end

local function getNumberOfHistoryItems(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not ffi or not loreCore then return {} end

    local numHistoryItems = ffi.new("intptr_t[1]")
    local result = loreCore.get_number_of_history_items(dbPath, numHistoryItems)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
        return {}
    end
end

local function readHistoryItems(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not ffi or not loreCore then return {} end

    local numHistoryItems = getNumberOfHistoryItems(dbPath)
    if not numHistoryItems then return {} end

    local cHistoryItems = ffi.new("CHistoryItem[?]", ffi.number(numHistoryItems[0]))

    local result = loreCore.read_history_items(dbPath, cHistoryItems)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
        return {}
    end

    for i = 0, (ffi.number(numHistoryItems[0]) - 1) do
        local cHistoryItem = cHistoryItems[i]
        local historyItem = {}
        historyItem.label = ffi.string(cHistoryItem.label)
        historyItem.content = ffi.string(cHistoryItem.content)
        historyItem.is_concerns_others = ffi.boolean(cHistoryItem.is_concerns_others)
        historyItem.is_secret = ffi.boolean(cHistoryItem.is_secret)
        historyItem.year = ffi.number(cHistoryItem.year)
        historyItem.day = ffi.number(cHistoryItem.day)
        historyItem.originator = ffi.string(cHistoryItem.originator)
        historyItem.year_format = ffi.string(cHistoryItem.year_format)
        table.insert(AllHistoryItems, historyItem)
    end
end

TexApi.readLoreFromDatabase = function(dbPath)
    GetLib() --Load the library if it hasn't been loaded yet.
    readEntities(dbPath)
end
