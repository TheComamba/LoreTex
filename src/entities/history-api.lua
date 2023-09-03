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
	SetProtectedField(item, "properties", {})

	if addToAll then
		AllHistoryItems[#AllHistoryItems + 1] = item
	end
	return item
end

local function setDay(historyItem, day)
	if not day then
		SetProtectedField(historyItem, "day", nil)
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

local function addEntities(properties, key, labels)
	for _, label in pairs(labels) do
		local entity = GetMutableEntityFromAll(label)
		AddToProtectedField(properties, key, entity)
	end
end

local function scanContentForProperties(properties, content)
	addEntities(properties, "birthOf", ScanStringForCmd(content, "birthof"))
	addEntities(properties, "deathOf", ScanStringForCmd(content, "deathof"))

	local concernsAllMentionedEntities = IsEmpty(GetProtectedTableReferenceField(properties, "onlyConcerns"))
	if concernsAllMentionedEntities then
		addEntities(properties, "additionalConcerns", ScanStringForCmd(content, "concerns"))
		addEntities(properties, "notConcerns", ScanStringForCmd(content, "notconcerns"))
	end
end

local function getHistoryMentions(item)
	local content = GetProtectedStringField(item, "content")
	return GetMentionedEntities(content)
end

function GetHistoryConcerns(item)
	local properties = GetProtectedTableReferenceField(item, "properties")
	local onlyConcerns = GetProtectedTableReferenceField(properties, "onlyConcerns")
	if not IsEmpty(onlyConcerns) then
		return onlyConcerns
	end

	local concernsTmp = {}
	UniqueAppend(concernsTmp, getHistoryMentions(item))
	UniqueAppend(concernsTmp, GetProtectedTableReferenceField(properties, "additionalConcerns"))
	UniqueAppend(concernsTmp, GetProtectedTableReferenceField(properties, "birthOf"))
	UniqueAppend(concernsTmp, GetProtectedTableReferenceField(properties, "deathOf"))

	local notConcerns = GetProtectedTableReferenceField(properties, "notConcerns")
	local actualConcerns = {}
	for _, entity in pairs(concernsTmp) do
		if not IsIn(entity, notConcerns) then
			Append(actualConcerns, entity)
			if not IsEntity(entity) then
				LogError { "This entity is not an entity:", DebugPrint(entity) }
				return {}
			end
		end
	end
	return actualConcerns
end

local function addSpecialyearsToEntities(field, year, entities)
	for _, entity in pairs(entities) do
		SetProtectedField(entity, field, year)
	end
end

local function processHistoryItem(item)
	if not IsHistoryInputOk("ProcessEvent", item) then
		return
	end

	local properties = GetProtectedTableReferenceField(item, "properties")
	local content = GetProtectedStringField(item, "content")
	scanContentForProperties(properties, content)

	local year = GetProtectedNullableField(item, "year")
	addSpecialyearsToEntities("born", year, GetProtectedTableReferenceField(properties, "birthOf"))
	addSpecialyearsToEntities("died", year, GetProtectedTableReferenceField(properties, "deathOf"))

	local concerns = GetHistoryConcerns(item)
	if #concerns == 0 then
		LogError { "This history item concerns nobody:", DebugPrint(item) }
	end
	for _, entity in pairs(concerns) do
		if not IsIn(item, GetProtectedTableReferenceField(entity, "historyItems")) then
			AddToProtectedField(entity, "historyItems", item)
		end
	end
end

function AddHistory(arg)
	if not IsArgOk("addHistory", arg, { "year", "event" }, { "day", "isConcernsOthers", "isSecret", "label", "originator",
			"yearFmt" }) then
		return
	end

	local item = NewHistoryItem(true)

	SetYear(item, arg.year, arg.yearFmt)
	setDay(item, arg.day)
	SetProtectedField(item, "content", arg.event)

	local properties = GetProtectedTableReferenceField(item, "properties")
	if arg.isSecret then
		SetProtectedField(properties, "isSecret", arg.isSecret)
	end

	if arg.isOnlyHere then
		AddToProtectedField(properties, "onlyConcerns", arg.originator)
	elseif arg.originator then
		AddToProtectedField(properties, "additionalConcerns", arg.originator)
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
	arg.isOnlyHere = true
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
