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
        LogError("This history item concerns nobody: " ..DebugPrint(historyItem))
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

local function addHistoryToEntity(entity)
    local history = {}
    for key, historyItem in pairs(Histories) do
        setSecrecy(historyItem)
        setShown(historyItem)
        if IsShown(historyItem) then
            local originator = GetEntity(historyItem["originator"])
            local concerns = historyItem["concerns"]
            if IsIn(entity["label"], concerns) then
                if isAcceptsHistoryFrom(entity, originator) then
                    AddHistoryItemToHistory(historyItem, history)
                end
            end
        end
    end
    SetDescriptor(entity, HistoryCaption, history)
end

function AddHistoryDescriptors()
    for key, entity in pairs(Entities) do
        addHistoryToEntity(entity)
    end
end
