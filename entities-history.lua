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

local function addHistoryToEntities(historyItem, entities)
    local originator = {}
    local originatorLabel = historyItem["originator"]
    if not IsEmpty(originatorLabel) then
        originator = GetEntity(originatorLabel)
    end
    local concerns = historyItem["concerns"]
    for key, label in pairs(concerns) do
        local concernedEntity = GetMutableEntity(label, entities)
        if not IsEmpty(concernedEntity) then
            if isAcceptsHistoryFrom(concernedEntity, originator) then
                local history = getHistory(concernedEntity)
                AddHistoryItemToHistory(historyItem, history)
                SetDescriptor(concernedEntity, Tr("history"), history)
            end
        end
    end
end

local function addHistoryDescriptors(entities)
    StartBenchmarking("addHistoryDescriptors")
    for key, historyItem in pairs(Histories) do
        if isHistoryShown(historyItem) then
            addHistoryToEntities(historyItem, entities)
        end
    end
    StopBenchmarking("addHistoryDescriptors")
end

function ProcessHistory(entities)
    StartBenchmarking("ProcessHistory")
    for key, entity in pairs(entities) do
        AddLifestageHistoryItemsToNPC(entity)
    end
    addHistoryDescriptors(entities)
    StopBenchmarking("ProcessHistory")
end
