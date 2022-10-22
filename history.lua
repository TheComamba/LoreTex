Histories = {}
Append(ProtectedDescriptors, { "historyItems" })

function AddHistoryItemToHistory(historyItem, history)
	local year = historyItem["year"]
	local day = historyItem["day"]
	local event = historyItem["event"]
	if historyItem["isSecret"] ~= nil and historyItem["isSecret"] then
		event = "(" .. CapFirst(Tr("secret")) .. ") " .. event
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
	local concerns = {}
	if not IsEmpty(originator) then
		local originatorLabel = GetMainLabel(originator)
		if IsEmpty(originatorLabel) then
			LogError("This originator has no label: " .. DebugPrint(originator))
			return {}
		end
		item["originator"] = originatorLabel
		Append(concerns, originatorLabel)
	end
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

	UniqueAppend(concerns, ScanForCmd(event, "concerns"))
	UniqueAppend(concerns, ScanForCmd(event, "deathof"))
	UniqueAppend(concerns, ScanForCmd(event, "birthof"))
	for key1, refType in pairs(RefTypes) do
		UniqueAppend(concerns, ScanForCmd(event, refType))
	end
	item["concerns"] = concerns
	item["birthof"] = ScanForCmd(event, "birthof")
	item["deathof"] = ScanForCmd(event, "deathof")

	for key, concernedLabel in pairs(concerns) do
		local entity = GetMutableEntityFromAll(concernedLabel)
		if entity["historyItems"] == nil then
			entity["historyItems"] = {}
		end
		entity["historyItems"][#entity["historyItems"]+1] = item
	end

	if isSecret ~= nil then
		item["isSecret"] = isSecret
	end

	item["event"] = event
	return item
end

local function addSpecialyearsToEntities(field, year, labels)
	for key, label in pairs(labels) do
		local entity = GetMutableEntityFromAll(label)
		entity[field] = year
	end
end

function AddEvent(originator, year, event, day, isSecret)
	StartBenchmarking("AddEvent")
	if originator ~= nil and type(originator) ~= "table" then
		LogError("Called with " .. DebugPrint(originator))
		StopBenchmarking("AddEvent")
		return
	elseif IsEmpty(year) then
		LogError(originator .. " has a history item without a year!")
		StopBenchmarking("AddEvent")
		return
	end
	if IsEmpty(day) then
		day = 0
	end
	local historyItem = newHistoryItem(originator, year, event, day, isSecret)
	Histories[#Histories + 1] = historyItem
	addSpecialyearsToEntities("born", historyItem["year"], historyItem["birthof"])
	addSpecialyearsToEntities("died", historyItem["year"], historyItem["deathof"])
	StopBenchmarking("AddEvent")
end

function HistoryEventString(yearAndDay, history)
	local year = yearAndDay[1]
	local day = yearAndDay[2]
	local out = AnnoString(year)
	if day > 0 then
		out = out .. ", " .. Tr("day") .. " " .. Date(day, {})
	end
	return out .. ": " .. history[year][day]
end

function ListHistory(history)
	local years = {}
	for year, daysAndEvents in pairs(history) do
		if year <= CurrentYearVin or IsShowFuture then
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
