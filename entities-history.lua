local function isAcceptsHistoryFrom(receiverLabel, originatorLabel)
    local receiver = Entities[receiverLabel]
    local originator = Entities[originatorLabel]
    if IsChar(originator) and IsPlace(receiver) then
        return false
    else
        return true
    end
end

local function addHistoryToEntity(label)
    local history = {}
    for key, historyItem in pairs(Histories) do
        local concerns = historyItem["concerns"]
        if IsIn(label, concerns) then
            if isAcceptsHistoryFrom(label, historyItem["originator"]) then
                AddHistoryItemToHistory(historyItem, history)
            end
        end
    end
    AddDescriptor(label, HistoryCaption, history)
end

function AddHistoryDescriptors()
    for key, label in pairs(PrimaryRefs) do
        addHistoryToEntity(label)
    end
end
