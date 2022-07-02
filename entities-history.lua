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

function AddHistoryRefsToSecondary()
    for key1, historyItem in pairs(Histories) do
        local concerns = historyItem["concerns"]
        if IsContainsPrimary(concerns) then
            for key2, label in pairs(concerns) do
                if not IsIn(label, PrimaryRefs) then
                    AddRef(label, SecondaryRefs)
                end
            end
        end
    end
end