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
	if day == nil then
		day = 0
	end
	if history[year][day] == nil then
		history[year][day] = event
	else
		history[year][day] = history[year][day] .. [[\\]] .. event
	end
end

function EmptyHistoryItem()
	local item = {}
	item["originator"] = nil
	item["day"] = nil
	item["year"] = nil
	item["yearFormat"] = nil
	item["event"] = ""
	item["isSecret"] = false
	item["isConcernsOthers"] = true
	return item
end

function SetDay(historyItem, day)
	local dayNumber = tonumber(day)
	if dayNumber == nil then
		LogError("Could not convert to number:" .. DebugPrint(day))
	else
		historyItem["day"] = dayNumber
	end
end

function SetYear(historyItem, year)
	local yearNumber = tonumber(year)
	if yearNumber == nil then
		LogError("Could not convert to number:" .. DebugPrint(year))
	else
		local yearFmt = historyItem["yearFormat"]
		if not IsEmpty(yearFmt) then
			yearNumber = ConvertYearToVin(yearNumber, yearFmt)
		end
		historyItem["day"] = yearNumber
	end
end

local function collectConcerns(item)
	local concernsPrelim = {}
	UniqueAppend(concernsPrelim, ScanForCmd(item["event"], "concerns"))
	UniqueAppend(concernsPrelim, item["birthof"])
	UniqueAppend(concernsPrelim, item["deathof"])
	UniqueAppend(concernsPrelim, item["originator"])
	for key1, refType in pairs(RefTypes) do
		UniqueAppend(concernsPrelim, ScanForCmd(item["event"], refType))
	end
	local notConcerns = ScanForCmd(item["event"], "notconcerns")
	local concerns = {}
	for key, concerned in pairs(concernsPrelim) do
		if not IsIn(concerned, notConcerns) then
			Append(concerns, concerned)
		end
	end
	item["concerns"] = concerns
end

local function addSpecialyearsToEntities(field, year, labels)
	for key, label in pairs(labels) do
		local entity = GetMutableEntityFromAll(label)
		entity[field] = year
	end
end

function ProcessEvent(item)
	StartBenchmarking("ProcessEvent")
	item["birthof"] = ScanForCmd(item["event"], "birthof")
	item["deathof"] = ScanForCmd(item["event"], "deathof")
	if item["isConcernsOthers"] then
		collectConcerns(item)
	else
		item["concerns"] = { item["originator"] }
	end

	for key, concernedLabel in pairs(item["concerns"]) do
		local entity = GetMutableEntityFromAll(concernedLabel)
		if entity["historyItems"] == nil then
			entity["historyItems"] = {}
		end
		entity["historyItems"][#entity["historyItems"] + 1] = item
	end

	addSpecialyearsToEntities("born", item["year"], item["birthof"])
	addSpecialyearsToEntities("died", item["year"], item["deathof"])
	Histories[#Histories + 1] = item

	StopBenchmarking("ProcessEvent")
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
