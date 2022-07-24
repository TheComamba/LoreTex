local function isAcceptsHistoryFrom(receiverLabel, originatorLabel)
    local receiver = Entities[receiverLabel]
    local originator = Entities[originatorLabel]
    if IsChar(originator) and IsPlace(receiver) then
        return false
    else
        return true
    end
end

local function isConcernsSecret(historyItem)
    if historyItem == nil then
        LogError("concernsSecret called with nil value")
        return false
    end
    local concerns = historyItem["concerns"]
    if concerns == nil then
        LogError("This history item concerns nobody:" .. historyItem["event"])
        return false
    end
    for key, label in pairs(concerns) do
        if IsSecret(label) then
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
        LogError("isAllConcnernsShown called with nil value")
        return false
    end
    local concerns = historyItem["concerns"]
    if concerns == nil then
        LogError("This history item concerns nobody:" .. historyItem["event"])
        return false
    end
    for key, label in pairs(concerns) do
        if not IsShown(label) then
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

local function addHistoryToEntity(label)
    local history = {}
    for key, historyItem in pairs(Histories) do
        setSecrecy(historyItem)
        setShown(historyItem)
        if IsShown(historyItem) then
            local concerns = historyItem["concerns"]
            if IsIn(label, concerns) then
                if isAcceptsHistoryFrom(label, historyItem["originator"]) then
                    AddHistoryItemToHistory(historyItem, history)
                end
            end
        end
    end
    SetDescriptor(label, HistoryCaption, history)
end

function AddHistoryDescriptors()
    for label, entity in pairs(Entities) do
        addHistoryToEntity(label)
    end
end
