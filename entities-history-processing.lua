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
    elseif not IsShowFuture and historyItem["year"] > CurrentYearVin then
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

local function getHistory(entity)
    local history = entity[Tr("history")]
    if IsEmpty(history) then
        return {}
    else
        return history
    end
end

local function historyEventString(yearAndDay, history)
    local year = yearAndDay[1]
    local day = yearAndDay[2]
    local out = AnnoString(year)
    if day > 0 then
        out = out .. ", " .. Tr("day") .. " " .. Date(day, {})
    end
    return out .. ": " .. history[year][day]
end

local function historyItemToString(historyItem)
    local year = historyItem["year"]
    local day = historyItem["day"]
    local event = historyItem["event"]
    local history = {}
    if historyItem["isSecret"] ~= nil and historyItem["isSecret"] then
        event = "(" .. CapFirst(Tr("secret")) .. ") " .. event
    end
    if history[year] == nil then
        history[year] = {}
    end
    if day == nil then
        day = 0
    end
    if history[year][day] == nil then
        history[year][day] = event
    else
        history[year][day] = history[year][day] .. [[\\]] .. event
    end
    local yearAndDay = { year, day }
    return historyEventString(yearAndDay, history)
end

local function addHistoryToEntity(historyItem, entity)
    local history = getHistory(entity)
    Append(history, historyItemToString(historyItem))
    SetDescriptor(entity, Tr("history"), history)
end

local function sortHistoryItemsChronologically(a, b)
    if a["year"] ~= b["year"] then
        return a["year"] < b["year"]
    elseif b["day"] == nil then
        return false
    elseif a["day"] == nil then
        return true
    else
        return a["day"] < b["day"]
    end
end

local function addHistoryDescriptors(entity)
    StartBenchmarking("addHistoryDescriptors")
    local historyItems = entity["historyItems"]
    if historyItems == nil then
        historyItems = {}
    end
    table.sort(historyItems, sortHistoryItemsChronologically)
    for key, historyItem in pairs(historyItems) do
        if isHistoryShown(historyItem) then
            addHistoryToEntity(historyItem, entity)
        end
    end
    StopBenchmarking("addHistoryDescriptors")
end

function ProcessHistory(entity)
    StartBenchmarking("ProcessHistory")
    AddLifestageHistoryItemsToNPC(entity)
    addHistoryDescriptors(entity)
    StopBenchmarking("ProcessHistory")
end
