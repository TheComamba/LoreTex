local function isAcceptsHistoryFrom(receiver, originator)
    if IsChar(originator) and IsPlace(receiver) then
        return false
    elseif IsAssociation(originator) and IsPlace(receiver) then
        return false
    elseif IsChar(originator) and IsSpecies(receiver) then
        return false
    else
        return true
    end
end

local function isConcernsUnrevealed(historyItem)
    if historyItem == nil then
        LogError("called with nil value")
        return false
    end
    local concerns = historyItem["concerns"]
    if concerns == nil then
        LogError("This history item concerns nobody:" .. DebugPrint(historyItem))
        return false
    end
    for key, label in pairs(concerns) do
        local entity = GetEntity(label)
        if IsEntitySecret(entity) and not IsRevealed(entity) then
            return true
        end
    end
    return false
end

local function isAllConcnernsShown(historyItem)
    if historyItem == nil then
        LogError("called with nil value")
        return false
    end
    local concerns = historyItem["concerns"]
    if concerns == nil then
        LogError("This history item concerns nobody: " .. DebugPrint(historyItem))
        return false
    end
    for key, label in pairs(concerns) do
        if not IsEntityShown(GetEntity(label)) then
            return false
        end
    end
    return true
end

local function isHistoryShown(historyItem)
    if not isAllConcnernsShown(historyItem) then
        return false
    elseif not IsShowFuture and historyItem["year"] > CurrentYearVin then
        return false
    elseif not IsShowSecrets then
        if historyItem["isSecret"] ~= nil and historyItem["isSecret"] then
            return false
        elseif isConcernsUnrevealed(historyItem) then
            return false
        else
            return true
        end
    else
        return true
    end
end

local function getHistory(entity)
    local history = entity[Tr("history")]
    if IsEmpty(history) then
        return {}
    else
        return history
    end
end

local function addHistoryToEntity(historyItem, entity)
    local originator = {}
    local originatorLabel = historyItem["originator"]
    if not IsEmpty(originatorLabel) then
        originator = GetEntity(originatorLabel)
    end
    if isAcceptsHistoryFrom(entity, originator) then
        local history = getHistory(entity)
        AddHistoryItemToHistory(historyItem, history)
        SetDescriptor(entity, Tr("history"), history)
    end
end

local function addHistoryDescriptors(entity)
    StartBenchmarking("addHistoryDescriptors")
    local historyItems = entity["historyItems"]
    if historyItems == nil then
        historyItems = {}
    end
    for key, historyItem in pairs(historyItems) do
        if isHistoryShown(historyItem) then
            addHistoryToEntity(historyItem, entity)
        end
    end
    StopBenchmarking("addHistoryDescriptors")
end

function ProcessHistory(entities)
    StartBenchmarking("ProcessHistory")
    for key, entity in pairs(entities) do
        AddLifestageHistoryItemsToNPC(entity)
        addHistoryDescriptors(entity)
    end
    StopBenchmarking("ProcessHistory")
end
