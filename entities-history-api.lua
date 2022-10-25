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
		historyItem["year"] = yearNumber
	end
end

function SetYearFmt(historyItem, fmt)
	if IsEmpty(fmt) then
		LogError("Called with unknown year format for history item:" .. DebugPrint(historyItem))
	else
		historyItem["yearFormat"] = fmt
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


	if IsEmpty(item["year"]) then
		LogError("This event has no year:" .. DebugPrint(item))
		item["year"] = 1e6
	end
	if IsEmpty(item["day"]) then
		item["day"] = nil
	end
	if IsEmpty(item["concerns"]) then
		LogError("This history item concerns nobody:" .. DebugPrint(item))
	end

	StopBenchmarking("ProcessEvent")
end
