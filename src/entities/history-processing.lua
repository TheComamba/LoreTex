local function historyItemToString(historyItem, isPrintDate)
    local content = GetProtectedStringField(historyItem, "content")
    local properties = GetProtectedTableReferenceField(historyItem, "properties")
    local isSecret = GetProtectedNullableField(properties, "isSecret") or IsConcernsOrMentionsSecret(historyItem)
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
    Append(out, content)
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
    local labels = {}
    for key, item in pairs(items) do
        local label = GetProtectedNullableField(item, "label")
        if not IsIn(label, labels) then
            out[#out + 1] = item
            Append(labels, label)
        end
    end
    return out
end

local function addHistoryDescriptors(entity)
    local historyItems = GetProtectedTableReferenceField(entity, "historyItems")
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
    AddLifestageHistoryItems(entity)
    addHistoryDescriptors(entity)
end
