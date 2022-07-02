local function addHistoryToEntity(label)
    local history = {}
    for key, historyItem in pairs(Histories) do
        local concerns = historyItem["concerns"]
        if IsIn(label, concerns) then
            AddHistoryItemToHistory(historyItem, history)
        end
    end
    AddDescriptor(label, HistoryCaption, history)
end

function AddHistoryDescriptorsToPrimaryRefs()
    for key, label in pairs(PrimaryRefs) do
        addHistoryToEntity(label)
    end
end
