local historyItemCounter = 1

StateResetters[#StateResetters + 1] = function()
	historyItemCounter = 1
end

local function IsHistoryItemOk(caller, item)
	local required = {}
	Append(required, GetProtectedDescriptor("counter"))
	Append(required, GetProtectedDescriptor("content"))
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
		local yearFmt = GetProtectedNullableField(historyItem, "yearFormat")
		if yearFmt ~= nil then
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

function AddMentions(entity, content)
	local mentionedLabels = ScanContentForMentionedRefs(content)
	for key, label in pairs(mentionedLabels) do
		local mentioned = GetMutableEntityFromAll(label)
		AddToProtectedField(entity, "mentions", mentioned)
	end
end

local function addConcerns(entity, content)
	local originator = GetProtectedNullableField(entity, "originator")
	if originator ~= nil then
		AddToProtectedField(entity, "concerns", originator)
	end
	if GetProtectedNullableField(entity, "isConcernsOthers") then
		local concernesLabels = {}
		for key, mentioned in pairs(GetProtectedTableField(entity, "mentions")) do
			local label = GetProtectedStringField(mentioned, "label")
			if label ~= "" then
				UniqueAppend(concernesLabels, label)
			end
		end
		if GetProtectedNullableField(entity, "year") ~= nil then
			UniqueAppend(concernesLabels, ScanStringForCmd(content, "concerns"))
			UniqueAppend(concernesLabels, GetProtectedTableFieldReference(entity, "birthof"))
			UniqueAppend(concernesLabels, GetProtectedTableFieldReference(entity, "deathof"))
		end
		local notConcerns = ScanForCmd(content, "notconcerns")
		for key, concernedLabel in pairs(concernesLabels) do
			if concernedLabel ~= "" and not IsIn(concernedLabel, notConcerns) then
				local concernedEntity = GetMutableEntityFromAll(concernedLabel)
				AddToProtectedField(entity, "concerns", concernedEntity)
			end
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

	local event = GetProtectedStringField(item, "content")
	SetProtectedField(item, "birthof", ScanStringForCmd(event, "birthof"))
	SetProtectedField(item, "deathof", ScanStringForCmd(event, "deathof"))

	local content = GetProtectedStringField(item, "content")
	AddMentions(item, content)
	addConcerns(item, content)
	for key, entity in pairs(GetProtectedTableField(item, "concerns")) do
		AddToProtectedField(entity, "historyItems", item)
	end

	local year = GetProtectedNullableField(item, "year")
	addSpecialyearsToEntities("born", year, GetProtectedTableFieldReference(item, "birthof"))
	addSpecialyearsToEntities("died", year, GetProtectedTableFieldReference(item, "deathof"))

	if IsEmpty(GetProtectedNullableField(item, "day")) then
		SetProtectedField(item, "day", nil)
	end
	if IsEmpty(GetProtectedTableField(item, "concerns")) then
		LogError("This history item concerns nobody:" .. DebugPrint(item))
	end
end

local function addHistory(arg)
	if not IsArgOk("addHistory", arg, { "year", "event" }, { "day", "isConcernsOthers", "isSecret", "yearFmt" }) then
		return
	end
	local item = NewHistoryItem()
	SetProtectedField(item, "originator", CurrentEntity)
	setDay(item, arg.day)
	SetYear(item, arg.year)
	SetProtectedField(item, "content", arg.event)
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
		arg.year = RemoveYearOffset(arg.year, arg.yearFmt)
	end
	SetProtectedField(CurrentEntity, "born", arg.year)
end

TexApi.died = function(arg)
	addHistory(arg)
	if not IsEmpty(arg.yearFmt) then
		arg.year = RemoveYearOffset(arg.year, arg.yearFmt)
	end
	SetProtectedField(CurrentEntity, "died", arg.year)
end
