local function isConcernsUnrevealed(historyItem)
    for key, label in pairs(historyItem["concerns"]) do
        local entity = GetEntity(label)
        if IsEntitySecret(entity) and not IsRevealed(entity) then
            return true
        end
    end
    return false
end

local function isAllConcnernsShown(historyItem)
    for key, label in pairs(historyItem["concerns"]) do
        if not IsEntityShown(GetEntity(label)) then
            return false
        end
    end
    return true
end

local function isHistoryShown(historyItem)
    if IsEmpty(historyItem) then
        return false
    elseif not isAllConcnernsShown(historyItem) then
        return false
    elseif not IsShowFuture and IsFutureEvent(historyItem) then
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

local function eventToString(year, day, event, isSecret)
    local history = {}
    local out = {}
    if year ~= nil then
        Append(out, YearAndDateString(year, day))
        Append(out, [[:\\]])
    end
    if isSecret ~= nil and isSecret then
        Append(out, "(")
        Append(out, CapFirst(Tr("secret")))
        Append(out, ") ")
    end
    Append(out, event)
    return table.concat(out)
end

local function sortHistoryItemsChronologically(a, b)
    if a["year"] ~= b["year"] then
        return a["year"] < b["year"]
    elseif a["day"] == nil and b["day"] == nil then
        return a["counter"] < b["counter"]
    elseif b["day"] == nil then
        return false
    elseif a["day"] == nil then
        return true
    elseif a["day"] ~= b["day"] then
        return a["day"] < b["day"]
    else
        return a["counter"] < b["counter"]
    end
end

local function isSameDate(item1, item2)
    if item1["year"] ~= item2["year"] then
        return false
    elseif item1["day"] == nil and item2["day"] == nil then
        return true
    elseif item1["day"] == nil then
        return false
    elseif item2["day"] == nil then
        return false
    else
        return item1["day"] == item2["day"]
    end
end

local function addHistoryDescriptors(entity)
    StartBenchmarking("addHistoryDescriptors")
    local historyItems = entity["historyItems"]
    if historyItems == nil then
        historyItems = {}
    end
    table.sort(historyItems, sortHistoryItemsChronologically)
    local processedHistory = {}
    for key, historyItem in pairs(historyItems) do
        if isHistoryShown(historyItem) then
            local year = historyItem["year"]
            local day = historyItem["day"]
            if key > 1 and isSameDate(historyItem, historyItems[key - 1]) then
                year = nil
                day = nil
            end
            Append(processedHistory, eventToString(year, day, historyItem["event"], historyItem["isSecret"]))
        end
    end
    SetDescriptor(entity, Tr("history"), processedHistory)
    StopBenchmarking("addHistoryDescriptors")
end

function ProcessHistory(entity)
    StartBenchmarking("ProcessHistory")
    AddLifestageHistoryItemsToNPC(entity)
    addHistoryDescriptors(entity)
    StopBenchmarking("ProcessHistory")
end
