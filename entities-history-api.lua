local historyItemCounter = 1
function EmptyHistoryItem()
	local item = {}
	SetProtectedField(item, "isSecret", false)
	SetProtectedField(item, "isConcernsOthers", true)
	SetProtectedField(item, "counter", historyItemCounter)
	historyItemCounter = historyItemCounter + 1
	return item
end

function SetDay(historyItem, day)
	if IsEmpty(day) then
		return
	end
	local dayNumber = tonumber(day)
	if dayNumber == nil then
		LogError("Could not convert to number:" .. DebugPrint(day))
	else
		SetProtectedField(historyItem, "day", dayNumber)
	end
end

function SetYear(historyItem, year)
	local yearNumber = tonumber(year)
	if yearNumber == nil then
		LogError("Could not convert to number:" .. DebugPrint(year))
	else
		local yearFmt = GetProtectedField(historyItem, "yearFormat")
		if not IsEmpty(yearFmt) then
			yearNumber = RemoveYearOffset(yearNumber, yearFmt)
		end
		SetProtectedField(historyItem, "year", yearNumber)
	end
end

function SetYearFmt(historyItem, label)
	if IsEmpty(label) then
		LogError("Called with empty year format for history item:" .. DebugPrint(historyItem))
		return
	end
	local fmt = GetEntity(label)
	if IsEmpty(fmt) then
		LogError("No format entity with label \"" ..
			label .. "\" was found. Note that currently the format entity has to be defined before it is used.")
		return
	end
	SetProtectedField(historyItem, "yearFormat", fmt)
end

local function collectConcerns(item)
	local concernsPrelim = {}
	local event = GetProtectedField(item, "event")
	UniqueAppend(concernsPrelim, ScanForCmd(event, "concerns"))
	UniqueAppend(concernsPrelim, GetProtectedField(item, "birthof"))
	UniqueAppend(concernsPrelim, GetProtectedField(item, "deathof"))
	UniqueAppend(concernsPrelim, GetProtectedField(item, "originator"))
	for key1, refType in pairs(RefTypes) do
		UniqueAppend(concernsPrelim, ScanForCmd(event, refType))
	end
	local notConcerns = ScanForCmd(event, "notconcerns")
	local concerns = {}
	for key, concerned in pairs(concernsPrelim) do
		if not IsIn(concerned, notConcerns) then
			Append(concerns, concerned)
		end
	end
	SetProtectedField(item, "concerns", concerns)
end

local function addSpecialyearsToEntities(field, year, labels)
	for key, label in pairs(labels) do
		local entity = GetMutableEntityFromAll(label)
		SetProtectedField(entity, field, year)
	end
end

function ProcessEvent(item)
	StartBenchmarking("ProcessEvent")

	local event = GetProtectedField(item, "event")
	SetProtectedField(item, "birthof", ScanForCmd(event, "birthof"))
	SetProtectedField(item, "deathof", ScanForCmd(event, "deathof"))
	if GetProtectedField(item, "isConcernsOthers") then
		collectConcerns(item)
	else
		local originator = GetProtectedField(item, "originator")
		AddToProtectedField(item, "concerns", originator)
	end

	for key, concernedLabel in pairs(GetProtectedField(item, "concerns")) do
		local entity = GetMutableEntityFromAll(concernedLabel)
		AddToProtectedField(entity, "historyItems", item)
	end

	local year = GetProtectedField(item, "year")
	addSpecialyearsToEntities("born", year, GetProtectedField(item, "birthof"))
	addSpecialyearsToEntities("died", year, GetProtectedField(item, "deathof"))


	if IsEmpty(year) then
		LogError("This event has no year:" .. DebugPrint(item))
		SetProtectedField(item, "year", 1e6)
	end
	if IsEmpty(GetProtectedField(item, "day")) then
		SetProtectedField(item, "day", nil)
	end
	if IsEmpty(GetProtectedField(item, "birthof")) then
		SetProtectedField(item, "birthof", nil)
	end
	if IsEmpty(GetProtectedField(item, "deathof")) then
		SetProtectedField(item, "deathof", nil)
	end
	if IsEmpty(GetProtectedField(item, "concerns")) then
		LogError("This history item concerns nobody:" .. DebugPrint(item))
	end

	StopBenchmarking("ProcessEvent")
end
