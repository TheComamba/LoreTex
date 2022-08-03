local function isAcceptsHistoryFrom(receiver, originator)
    if IsChar(originator) and IsPlace(receiver) then
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

local function addHistoryToEntities(historyItem)
    local originator = GetEntity(historyItem["originator"])
    local concerns = historyItem["concerns"]
    for key, label in pairs(concerns) do
        local concnerendEntity = GetEntity(label)
        if isAcceptsHistoryFrom(concnerendEntity, originator) then
            local history = getHistory(concnerendEntity)
            AddHistoryItemToHistory(historyItem, history)
            SetDescriptor(concnerendEntity, HistoryCaption, history)
        end
    end
end

function AddHistoryDescriptors()
    for key, historyItem in pairs(Histories) do
        setSecrecy(historyItem)
        setShown(historyItem)
        if IsShown(historyItem) then
            addHistoryToEntities(historyItem)
        end
    end
end
