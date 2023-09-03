AllHistoryItems = {}

StateResetters[#StateResetters + 1] = function()
	AllHistoryItems = {}
end

local function IsHistoryInputOk(caller, item)
	local required = {}
	local optional = {}
	Append(required, GetProtectedDescriptor("label"))
	Append(required, GetProtectedDescriptor("year"))
	Append(optional, GetProtectedDescriptor("day"))
	Append(required, GetProtectedDescriptor("content"))
	Append(optional, GetProtectedDescriptor("properties"))
	return IsArgOk(caller, item, required, optional)
end

function NewHistoryItem(addToAll)
	local item = {}
	SetProtectedField(item, "isSecret", false)

	if addToAll then
		AllHistoryItems[#AllHistoryItems + 1] = item
	end
	return item
end

local function setDay(historyItem, day)
	if IsEmpty(day) then
		return
	end
	local dayNumber = tonumber(day)
	if dayNumber == nil then
		LogError { "Could not convert to number:", DebugPrint(day) }
	else
		SetProtectedField(historyItem, "day", dayNumber)
	end
end

function SetYear(historyItem, year, yearFmt)
	local yearNumber = tonumber(year)
	if yearNumber == nil then
		LogError { "Could not convert to number:", DebugPrint(year) }
		return
	end

	if yearFmt ~= nil then
		yearNumber = YearWithoutOffset(yearNumber, yearFmt)
	end
	SetProtectedField(historyItem, "year", yearNumber)
end

function AddMentions(entity, content)
	local mentionedLabels = ScanContentForMentionedRefs(content)
	for key, label in pairs(mentionedLabels) do
		local mentioned = GetMutableEntityFromAll(label)
		AddToProtectedField(entity, "mentions", mentioned)
	end
end

local function addConcerns(entity, content)
	local concernsLabels = {}
	local originator = GetProtectedNullableField(entity, "originator")
	if originator ~= nil then
		UniqueAppend(concernsLabels, GetProtectedStringField(originator, "label"))
	end

	if GetProtectedNullableField(entity, "isConcernsOthers") then
		for key, mentioned in pairs(GetProtectedTableReferenceField(entity, "mentions")) do
			local label = GetProtectedStringField(mentioned, "label")
			if label ~= "" then
				UniqueAppend(concernsLabels, label)
			end
		end
		if GetProtectedNullableField(entity, "year") ~= nil then
			UniqueAppend(concernsLabels, ScanStringForCmd(content, "concerns"))
			UniqueAppend(concernsLabels, GetProtectedTableReferenceField(entity, "birthOf"))
			UniqueAppend(concernsLabels, GetProtectedTableReferenceField(entity, "deathOf"))
		end
	end

	local notConcerns = ScanForCmd(content, "notconcerns")
	for key, concernedLabel in pairs(concernsLabels) do
		if concernedLabel ~= "" and not IsIn(concernedLabel, notConcerns) then
			local concernedEntity = GetMutableEntityFromAll(concernedLabel)
			AddToProtectedField(entity, "concerns", concernedEntity)
		end
	end
end

local function addSpecialyearsToEntities(field, year, labels)
	for key, label in pairs(labels) do
		local entity = GetMutableEntityFromAll(label)
		SetProtectedField(entity, field, year)
	end
end

local function processHistoryItem(item)
	if not IsHistoryInputOk("ProcessEvent", item) then
		return
	end

	local event = GetProtectedStringField(item, "content")
	SetProtectedField(item, "birthOf", ScanStringForCmd(event, "birthOf"))
	SetProtectedField(item, "deathOf", ScanStringForCmd(event, "deathOf"))

	local content = GetProtectedStringField(item, "content")
	AddMentions(item, content)
	addConcerns(item, content)
	for key, entity in pairs(GetProtectedTableReferenceField(item, "concerns")) do
		if not IsIn(item, GetProtectedTableReferenceField(entity, "historyItems")) then
			AddToProtectedField(entity, "historyItems", item)
		end
	end

	local year = GetProtectedNullableField(item, "year")
	addSpecialyearsToEntities("born", year, GetProtectedTableReferenceField(item, "birthOf"))
	addSpecialyearsToEntities("died", year, GetProtectedTableReferenceField(item, "deathOf"))

	if IsEmpty(GetProtectedNullableField(item, "day")) then
		SetProtectedField(item, "day", nil)
	end
	if #(GetProtectedTableReferenceField(item, "concerns")) == 0 then
		LogError { "This history item concerns nobody:", DebugPrint(item) }
	end
end

function AddHistory(arg)
	if not IsArgOk("addHistory", arg, { "year", "event" }, { "day", "isConcernsOthers", "isSecret", "label", "originator",
			"yearFmt" }) then
		return
	end
	local item = NewHistoryItem(true)
	if arg.originator then
		SetProtectedField(item, "originator", arg.originator)
	end
	setDay(item, arg.day)
	SetYear(item, arg.year, arg.yearFmt)
	SetProtectedField(item, "content", arg.event)
	if not IsEmpty(arg.isConcernsOthers) then
		SetProtectedField(item, "isConcernsOthers", arg.isConcernsOthers)
	end
	if not IsEmpty(arg.isSecret) then
		SetProtectedField(item, "isSecret", arg.isSecret)
	end
	AssureUniqueHistoryLabel(item)
	processHistoryItem(item)
end

TexApi.addHistory = function(arg)
	arg.originator = CurrentEntity
	if arg.yearFmt and arg.yearFmt ~= "" then
		arg.yearFmt = GetMutableEntityFromAll(arg.yearFmt)
	else
		arg.yearFmt = nil
	end
	AddHistory(arg)
end

TexApi.addSecretHistory = function(arg)
	arg.isSecret = true
	TexApi.addHistory(arg)
end

TexApi.addHistoryOnlyHere = function(arg)
	arg.isConcernsOthers = false
	TexApi.addHistory(arg)
end

TexApi.born = function(arg)
	TexApi.addHistory(arg)
	if not IsEmpty(arg.yearFmt) then
		arg.year = YearWithoutOffset(arg.year, arg.yearFmt)
	end
	SetProtectedField(CurrentEntity, "born", arg.year)
end

TexApi.died = function(arg)
	TexApi.addHistory(arg)
	if not IsEmpty(arg.yearFmt) then
		arg.year = YearWithoutOffset(arg.year, arg.yearFmt)
	end
	SetProtectedField(CurrentEntity, "died", arg.year)
end
