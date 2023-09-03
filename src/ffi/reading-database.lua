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

    return ffi.number(numEntityColumns[0])
end

local function readEntityColumns(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not ffi or not loreCore then return {} end

    local numEntityColumns = getNumberOfEntityColumns(dbPath)
    if not numEntityColumns then return {} end

    local cEntityColumns = ffi.new("CEntityColumn[?]", numEntityColumns)

    local result = loreCore.read_entity_columns(dbPath, cEntityColumns)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
        return {}
    end

    local entityColumns = {}
    for i = 0, (numEntityColumns - 1) do
        local cEntityColumn = cEntityColumns[i]
        local entityColumn = {}
        entityColumn.label = ffi.string(cEntityColumn.label)
        entityColumn.descriptor = ffi.string(cEntityColumn.descriptor)
        entityColumn.description = ffi.string(cEntityColumn.description)
        table.insert(entityColumns, entityColumn)
    end
    return entityColumns
end

local function getNumberOfHistoryItems(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not ffi or not loreCore then return nil end

    local numHistoryItems = ffi.new("intptr_t[1]")
    local result = loreCore.get_number_of_history_items(dbPath, numHistoryItems)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
        return nil
    end

    return ffi.number(numHistoryItems[0])
end

local function readHistoryItemColumns(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not ffi or not loreCore then return {} end

    local numHistoryItems = getNumberOfHistoryItems(dbPath)
    if not numHistoryItems then return {} end

    local cHistoryItems = ffi.new("CHistoryItem[?]", numHistoryItems)

    local result = loreCore.read_history_items(dbPath, cHistoryItems)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
        return {}
    end

    local histoyItemColumns = {}
    for i = 0, (numHistoryItems - 1) do
        local cHistoryItem = cHistoryItems[i]
        local historyItem = {}
        historyItem.label = ffi.string(cHistoryItem.label)
        historyItem.year = ffi.number(cHistoryItem.year)
        historyItem.day = ffi.number(cHistoryItem.day)
        historyItem.content = ffi.string(cHistoryItem.content)
        historyItem.properties = ffi.string(cHistoryItem.properties)
        table.insert(histoyItemColumns, historyItem)
    end
    return histoyItemColumns
end

local function getNumberOfRelationships(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not ffi or not loreCore then return nil end

    local numRelationships = ffi.new("intptr_t[1]")
    local result = loreCore.get_number_of_relationships(dbPath, numRelationships)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
        return nil
    end
    return ffi.number(numRelationships[0])
end

local function readRelationshipColumns(dbPath)
    local ffi = GetFFIModule()
    local loreCore = GetLib()
    if not ffi or not loreCore then return {} end

    local numRelationships = getNumberOfRelationships(dbPath)
    if not numRelationships then return {} end

    local cRelationships = ffi.new("CEntityRelationship[?]", numRelationships)

    local result = loreCore.read_relationships(dbPath, cRelationships)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
        return {}
    end

    local relationshipColumns = {}
    for i = 0, (numRelationships - 1) do
        local cRelationship = cRelationships[i]
        local relationship = {}
        relationship.parent = ffi.string(cRelationship.parent)
        relationship.child = ffi.string(cRelationship.child)
        relationship.role = ffi.string(cRelationship.role)
        table.insert(relationshipColumns, relationship)
    end
    return relationshipColumns
end

TexApi.readLoreFromDatabase = function(dbPath)
    local entityColumns = readEntityColumns(dbPath)
    EntitiesFromColumns(entityColumns)
    local historyItemColumns = readHistoryItemColumns(dbPath)
    HistoryItemsFromColumns(historyItemColumns)
    local relationshipColumns = readRelationshipColumns(dbPath)
    RelationshipsFromColumns(relationshipColumns)
end
