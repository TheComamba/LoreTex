local function concernedAndOriginator(historyItem)
    local out = GetProtectedTableField(historyItem, "concerns")
    local originator = GetProtectedNullableField(historyItem, "originator")
    if originator ~= nil then
        out[#out+1] = originator
    end
    return out
    end

local function isConcernsUnrevealed(historyItem)
    for key, entity in pairs(concernedAndOriginator(historyItem)) do
        if IsEntitySecret(entity) and not IsRevealed(entity) then
            return true
        end
    end
    return false
end

local function isConcernsSecret(historyItem)
    for key, entity in pairs(concernedAndOriginator(historyItem)) do
        if IsEntitySecret(entity) then
            return true
        end
    end
    return false
end

local function isAllConcnernsShown(historyItem)
    for key, entity in pairs(concernedAndOriginator(historyItem)) do
        if not IsEntityShown(entity) then
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
        local isSecret = GetProtectedNullableField(historyItem, "isSecret")
        if isSecret ~= nil and isSecret then
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

local function historyItemToString(historyItem, isPrintDate)
    local event = GetProtectedStringField(historyItem, "content")
    local isSecret = GetProtectedNullableField(historyItem, "isSecret") or isConcernsSecret(historyItem)
    local out = {}
    if isPrintDate then
        Append(out, YearAndDayString(historyItem))
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

local function isSameDate(item1, item2)
    if GetProtectedNullableField(item1, "year") ~= GetProtectedNullableField(item2, "year") then
        return false
    end
    local day1 = GetProtectedNullableField(item1, "day")
    local day2 = GetProtectedNullableField(item2, "day")
    if day1 == nil and day2 == nil then
        return true
    elseif day1 == nil then
        return false
    elseif day2 == nil then
        return false
    else
        return day1 == day2
    end
end

local function collectHistoryItems(entity)
    local out = GetProtectedTableField(entity, "historyItems")
    local subEntities = GetProtectedTableField(entity, "subEntities")
    for key, subEntity in pairs(subEntities) do
        local subHistoryItems = GetProtectedTableField(subEntity, "historyItems")
        for key2, item in pairs(subHistoryItems) do
            out[#out + 1] = item
        end
    end
    return out
end

local function deleteDuplicateHistoryItems(items)
    local out = {}
    local counters = {}
    for key, item in pairs(items) do
        local counter = GetProtectedNullableField(item, "counter")
        if not IsIn(counter, counters) then
            out[#out + 1] = item
            Append(counters, counter)
        end
    end
    return out
end

local function addHistoryDescriptors(entity)
    StartBenchmarking("addHistoryDescriptors")
    local historyItems = collectHistoryItems(entity)
    historyItems = deleteDuplicateHistoryItems(historyItems)
    Sort(historyItems, "compareHistoryItems")
    local processedHistory = {}
    for key, historyItem in pairs(historyItems) do
        if isHistoryShown(historyItem) then
            local isPrintDate = (key == 1 or not isSameDate(historyItem, historyItems[key - 1]))
            Append(processedHistory, historyItemToString(historyItem, isPrintDate))
        end
    end
    if not IsEmpty(processedHistory) then
        SetDescriptor { entity = entity, descriptor = Tr("history"), description = processedHistory }
    end
    StopBenchmarking("addHistoryDescriptors")
end

function ProcessHistory(entity)
    StartBenchmarking("ProcessHistory")
    AddLifestageHistoryItemsToNPC(entity)
    addHistoryDescriptors(entity)
    StopBenchmarking("ProcessHistory")
end
