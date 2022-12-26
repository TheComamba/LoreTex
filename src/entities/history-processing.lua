local function historyItemToString(historyItem, isPrintDate)
    local event = GetProtectedStringField(historyItem, "content")
    local isSecret = GetProtectedInheritableField(historyItem, "isSecret") or IsConcernsOrMentionsSecret(historyItem)
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
    local historyItems = GetProtectedTableField(entity, "historyItems")
    historyItems = deleteDuplicateHistoryItems(historyItems)
    Sort(historyItems, "compareHistoryItems")
    local processedHistory = {}
    for key, historyItem in pairs(historyItems) do
        if IsHistoryShown(historyItem) then
            local isPrintDate = (key == 1 or not isSameDate(historyItem, historyItems[key - 1]))
            Append(processedHistory, historyItemToString(historyItem, isPrintDate))
        end
    end
    if #processedHistory > 0 then
        SetDescriptor { entity = entity, descriptor = Tr("history"), description = processedHistory }
    end
end

function ProcessHistory(entity)
    AddLifestageHistoryItemsToNPC(entity)
    addHistoryDescriptors(entity)
end
