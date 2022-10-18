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

local function isConcernsSecret(historyItem)
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
        if IsSecret(GetEntity(label)) then
            return true
        end
    end
    return false
end

local function setSecrecy(historyItem)
    if isConcernsSecret(historyItem) then
        historyItem["isSecret"] = true
    end
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
        if not IsShown(GetEntity(label)) then
            return false
        end
    end
    return true
end

local function setShown(historyItem)
    if historyItem["isShown"] == nil then
        historyItem["isShown"] = isAllConcnernsShown(historyItem)
    end
end

local function getHistory(entity)
    local history = entity[HistoryCaption]
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
                SetDescriptor(concernedEntity, HistoryCaption, history)
            end
        end
    end
end

local function addHistoryDescriptors(entities)
    for key, historyItem in pairs(Histories) do
        setSecrecy(historyItem)
        setShown(historyItem)
        if IsShown(historyItem) then
            addHistoryToEntities(historyItem, entities)
        end
    end
end

function ProcessHistory(entities)
    for key, entity in pairs(entities) do
        AddLifestageHistoryItemsToNPC(entity)
    end
    addHistoryDescriptors(entities)
end
