Histories = {}
HistoryCaption = "Histori\\\"e"

function AddHistoryItemToHistory(historyItem, history)
	local year = historyItem["year"]
	local day = historyItem["day"]
	local event = historyItem["event"]
	if IsSecret(historyItem) then
		event = "(Geheim) " .. event
	end
	if history[year] == nil then
		history[year] = {}
	end
	if history[year][day] == nil then
		history[year][day] = event
	else
		history[year][day] = history[year][day] .. [[\\]] .. event
	end
end

local function newHistoryItem(originator, year, event, day, isSecret)
	local item = {}
	item["originator"] = originator
	item["year"] = tonumber(year)
	if item["year"] == nil then
		LogError("Could not convert year \"" .. year .. "\" to number.")
		return {}
	end
	item["day"] = tonumber(day)
	if item["day"] == nil then
		LogError("Could not convert day \"" .. day .. "\" to number.")
		return {}
	end
	item["event"] = event
	local concerns = ScanForRefs(event)
	if not IsIn(originator, concerns) then
		concerns[#concerns + 1] = originator
	end
	item["concerns"] = concerns
	if isSecret ~= nil then
		item["isSecret"] = isSecret
	end
	return item
end

function AddEvent(originator, year, event, day, isSecret)
	if IsEmpty(day) then
		day = 0
	end
	if year <= CurrentYearVin then
		Histories[#Histories + 1] = newHistoryItem(originator, year, event, day, isSecret)
	end
end

function HistoryEventString(yearAndDay, history)
	local year = yearAndDay[1]
	local day = yearAndDay[2]
	local out = AnnoString(year)
	if day > 0 then
		out = out .. ", Tag " .. Date(day, {})
	end
	return out .. ": " .. history[year][day]
end

function ListHistory(history)
	local years = {}
	for year, daysAndEvents in pairs(history) do
		if year <= CurrentYearVin then
			years[#years + 1] = year
		end
	end
	table.sort(years)
	local yearsAndDays = {}
	for key1, year in pairs(years) do
		local days = {}
		for day, event in pairs(history[year]) do
			days[#days + 1] = day
		end
		table.sort(days)
		for key2, day in pairs(days) do
			yearsAndDays[#yearsAndDays + 1] = { year, day }
		end
	end

	return ListAll(yearsAndDays, HistoryEventString, history)
end
