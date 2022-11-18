local historyItemCounter = 1

local function IsHistoryItemOk(caller, item)
	local required = {}
	Append(required, GetProtectedDescriptor("counter"))
	Append(required, GetProtectedDescriptor("event"))
	Append(required, GetProtectedDescriptor("isConcernsOthers"))
	Append(required, GetProtectedDescriptor("isSecret"))
	Append(required, GetProtectedDescriptor("year"))
	local optional = {}
	Append(optional, GetProtectedDescriptor("day"))
	Append(optional, GetProtectedDescriptor("originator"))
	Append(optional, GetProtectedDescriptor("yearFormat"))
	return IsArgOk(caller, item, required, optional)
end

function NewHistoryItem()
	local item = {}
	SetProtectedField(item, "isSecret", false)
	SetProtectedField(item, "isConcernsOthers", true)
	SetProtectedField(item, "counter", historyItemCounter)
	historyItemCounter = historyItemCounter + 1
	return item
end

local function setDay(historyItem, day)
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

local function setYearFmt(historyItem, label)
	if IsEmpty(label) then
		LogError("Called with empty year format for history item:" .. DebugPrint(historyItem))
		return
	end
	local fmt = GetMutableEntityFromAll(label)
	SetProtectedField(historyItem, "yearFormat", fmt)
end

local function collectConcerns(item)
	local concernesLabels = {}
	local event = GetProtectedField(item, "event")
	UniqueAppend(concernesLabels, ScanForCmd(event, "concerns"))
	UniqueAppend(concernesLabels, GetProtectedField(item, "birthof"))
	UniqueAppend(concernesLabels, GetProtectedField(item, "deathof"))
	UniqueAppend(concernesLabels, GetProtectedField(item, "originator"))
	for key1, refType in pairs(RefTypes) do
		UniqueAppend(concernesLabels, ScanForCmd(event, refType))
	end
	local notConcerns = ScanForCmd(event, "notconcerns")
	for key, concernedLabel in pairs(concernesLabels) do
		if not IsIn(concernedLabel, notConcerns) then
			local concernedEntity = GetMutableEntityFromAll(concernedLabel)
			AddToProtectedField(item, "concerns", concernedEntity)
		end
	end
end

local function addSpecialyearsToEntities(field, year, labels)
	for key, label in pairs(labels) do
		local entity = GetMutableEntityFromAll(label)
		SetProtectedField(entity, field, year)
	end
end

local function processEvent(item)
	if not IsHistoryItemOk("ProcessEvent", item) then
		return
	end
	StartBenchmarking("ProcessEvent")

	local event = GetProtectedField(item, "event")
	SetProtectedField(item, "birthof", ScanForCmd(event, "birthof"))
	SetProtectedField(item, "deathof", ScanForCmd(event, "deathof"))
	if GetProtectedField(item, "isConcernsOthers") then
		collectConcerns(item)
	else
		local originator = GetProtectedField(item, "originator")
		AddToProtectedField(item, "concerns", GetMutableEntityFromAll(originator))
	end

	for key, entity in pairs(GetProtectedField(item, "concerns")) do
		AddToProtectedField(entity, "historyItems", item)
	end

	local year = GetProtectedField(item, "year")
	addSpecialyearsToEntities("born", year, GetProtectedField(item, "birthof"))
	addSpecialyearsToEntities("died", year, GetProtectedField(item, "deathof"))

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

local function addHistory(arg)
	if not IsArgOk("addHistory", arg, { "year", "event" }, { "day", "isConcernsOthers", "isSecret", "yearFmt" }) then
		return
	end
	local item = NewHistoryItem()
	SetProtectedField(item, "originator", GetMainLabel(CurrentEntity))
	setDay(item, arg.day)
	SetYear(item, arg.year)
	SetProtectedField(item, "event", arg.event)
	if not IsEmpty(arg.isConcernsOthers) then
		SetProtectedField(item, "isConcernsOthers", arg.isConcernsOthers)
	end
	if not IsEmpty(arg.isSecret) then
		SetProtectedField(item, "isSecret", arg.isSecret)
	end
	if not IsEmpty(arg.yearFmt) then
		setYearFmt(item, arg.yearFmt)
	end
	processEvent(item)
end

TexApi.addHistory = function(arg)
	addHistory(arg)
end

TexApi.addSecretHistory = function(arg)
	arg.isSecret = true
	addHistory(arg)
end

TexApi.addHistoryOnlyHere = function(arg)
	arg.isConcernsOthers = false
	addHistory(arg)
end

TexApi.born = function(arg)
	addHistory(arg)
	if not IsEmpty(arg.yearFmt) then
		local fmt = GetEntity(arg.yearFmt)
		arg.year = RemoveYearOffset(arg.year, fmt)
	end
	SetProtectedField(CurrentEntity, "born", arg.year)
end

TexApi.died = function(arg)
	addHistory(arg)
	if not IsEmpty(arg.yearFmt) then
		local fmt = GetEntity(arg.yearFmt)
		arg.year = RemoveYearOffset(arg.year, fmt)
	end
	SetProtectedField(CurrentEntity, "died", arg.year)
end
