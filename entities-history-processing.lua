local function isConcernsUnrevealed(historyItem)
    for key, label in pairs(GetProtectedField(historyItem, "concerns")) do
        local entity = GetEntity(label)
        if IsEntitySecret(entity) and not IsRevealed(entity) then
            return true
        end
    end
    return false
end

local function isConcernsSecret(historyItem)
    for key, label in pairs(GetProtectedField(historyItem, "concerns")) do
        local entity = GetEntity(label)
        if IsEntitySecret(entity) then
            return true
        end
    end
    return false
end

local function isAllConcnernsShown(historyItem)
    for key, label in pairs(GetProtectedField(historyItem, "concerns")) do
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
        local isSecret = GetProtectedField(historyItem, "isSecret")
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
    local event = GetProtectedField(historyItem, "event")
    local isSecret = GetProtectedField(historyItem, "isSecret") or isConcernsSecret(historyItem)
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
    if GetProtectedField(item1, "year") ~= GetProtectedField(item2, "year") then
        return false
    end
    local day1 = GetProtectedField(item1, "day")
    local day2 = GetProtectedField(item2, "day")
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

local function addHistoryDescriptors(entity)
    StartBenchmarking("addHistoryDescriptors")
    local historyItems = GetProtectedField(entity, "historyItems")
    if historyItems == nil then
        historyItems = {}
    end
    table.sort(historyItems, CompareHistoryItems)
    local processedHistory = {}
    for key, historyItem in pairs(historyItems) do
        if isHistoryShown(historyItem) then
            local isPrintDate = (key == 1 or not isSameDate(historyItem, historyItems[key - 1]))
            Append(processedHistory, historyItemToString(historyItem, isPrintDate))
        end
    end
    SetDescriptor { entity = entity, descriptor = Tr("history"), description = processedHistory }
    StopBenchmarking("addHistoryDescriptors")
end

function ProcessHistory(entity)
    StartBenchmarking("ProcessHistory")
    AddLifestageHistoryItemsToNPC(entity)
    addHistoryDescriptors(entity)
    StopBenchmarking("ProcessHistory")
end
