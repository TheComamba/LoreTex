Entities = {}
CurrentLabel = ""
CurrentCity = ""
CurrentRegion = ""
CurrentContinent = ""
PlaceTypes = {"continent", "region", "city"}
CharacterTypes = {"npc", "pc", "god"}
PlaceDepths = {{PlaceTypes[1], "section"},
				{PlaceTypes[2],"subsection"},
				{PlaceTypes[3],"subsubsection"}}
ProtectedDescriptors = {"name", "shortname", "type", "parent", "location", "born", "died", "species", "gender"}
OnlyMentioned = "zzz-nur-erwähnt"
Heimatlos = "zzz-heimatlos"
AddRef(OnlyMentioned,PrimaryRefs)
Entities[OnlyMentioned] = {}
Entities[OnlyMentioned]["name"] = "Nur erwähnt"
Entities[OnlyMentioned]["type"] = PlaceTypes[1]

local function isPlace(entity)
	local type = entity["type"]
	return type ~= nil and IsIn(entity["type"], PlaceTypes)
end

local function isChar(entity)
	local type = entity["type"]
	return type ~= nil and IsIn(entity["type"], CharacterTypes)
end

local function isOnlyMentioned(entity)
	return IsIn(OnlyMentioned, entity)
end

local function getEntitiesIf(condition)
	local out = {}
	for key, entity in pairs(Entities) do
		if condition(entity) then
			out[key] = entity
		end
	end
	return out
end

local function getShortname(label)
	if label == Heimatlos then
		return "Heimatlos"
	elseif Entities[label] == nil then
		return "Anderswo"
	elseif Entities[label]["shortname"] ~= nil then
		return Entities[label]["shortname"]
	elseif Entities[label]["name"] ~= nil then
		return Entities[label]["name"]
	else
		return "NO NAME"
	end
end

function AddDescriptor(label, descriptor, description)
	if IsStringEmpty(label) then
		return
	elseif IsStringEmpty(descriptor) then
		return
	elseif IsStringEmpty(description) then
		return
	end
	
	if Entities[label] == nil then
		Entities[label] = {}
	end
	Entities[label][descriptor] = description
end

function SetLocation(label, location)
	if Entities[label] == nil then
		return
	end
	
	if location ~= nil then
		Entities[label]["location"] = location
	elseif CurrentCity ~= "" then
		Entities[label]["location"] = CurrentCity
	elseif CurrentRegion ~= "" then
		Entities[label]["location"] = CurrentRegion
	elseif CurrentContinent ~= "" then
		Entities[label]["location"] = CurrentContinent
	end
end

local function listAllFromMap(listOfThings)
	local allLabels = {}
	for label,elem in pairs(listOfThings) do
		allLabels[#allLabels+1] = label
	end
	return ListAll(allLabels, NamerefString)
end

local function addNPCsToPlaces()
	for label,char in pairs(Entities) do
		if isChar(char) then
			local location = char["location"]
			if location ~= nil and Entities[location] ~= nil then
				if Entities[location]["NPCs"] == nil then
					Entities[location]["NPCs"] = {}
				end
				Entities[location]["NPCs"][label] = char["name"]
			end
		end
	end
end

local function descriptorsStringPrimaryRef(entity)
	local str = ""
	
	local descriptorsList = {}
	for descriptor, description in pairs(entity) do
		if not IsIn(descriptor, ProtectedDescriptors) then
			descriptorsList[#descriptorsList+1] = descriptor
		end
	end
	table.sort(descriptorsList)
	for key, descriptor in pairs(descriptorsList) do
		str = str..TexCmd("paragraph", descriptor)
		if descriptor == HistoryCaption then
			str = str..ListHistory(entity[descriptor])
		elseif type(entity[descriptor]) == "string" then
			str = str..entity[descriptor]
		elseif type(entity[descriptor]) == "table" then
			str = str..listAllFromMap(entity[descriptor])
		end
	end
	return str
end

local function descriptorsString(entity)
	if isOnlyMentioned(entity) then
		return TexCmd("hspace","1cm")
	else
		return descriptorsStringPrimaryRef(entity)
	end
end

local function createNPCsSortedByPlace()
	local sortedNPCs = {}
	sortedNPCs["labels"] = {}
	for label, char in pairs(Entities) do
		if isChar(char) then
			local city = char["location"]
			local region = nil
			
			if city == nil then
				city = Heimatlos
				region = "andere"
			elseif Entities[city] == nil then
				city = "notfound"
				region = "andere"
			elseif Entities[city]["type"] == "region" then
				region = city
				city = Heimatlos
			elseif Entities[city]["parent"] == nil then
				region = "andere"
			else
				region =  Entities[city]["parent"]
			end
			
			if not IsIn(region, sortedNPCs["labels"]) then
				sortedNPCs["labels"][#(sortedNPCs["labels"])+1] = region
				sortedNPCs[region] = {}
				sortedNPCs[region]["labels"] = {}
			end
			if not IsIn(city, sortedNPCs[region]["labels"]) then
				sortedNPCs[region]["labels"][#(sortedNPCs[region]["labels"])+1] = city
				sortedNPCs[region][city] = {}
				sortedNPCs[region][city]["labels"] = {}
			end
			sortedNPCs[region][city]["labels"][#(sortedNPCs[region][city]["labels"])+1] = label
		end
	end
	
	table.sort(sortedNPCs["labels"])
	for key1, regionLabel in pairs(sortedNPCs["labels"]) do
		tex.print(TexCmd("section","NPCs in "..getShortname(regionLabel)))
		table.sort(sortedNPCs[regionLabel]["labels"])
		for key2, cityLabel in pairs(sortedNPCs[regionLabel]["labels"]) do
			tex.print(TexCmd("subsection", "NPCs in "..getShortname(cityLabel)))
			if IsIn(cityLabel, PrimaryRefs) then
				tex.print("Siehe auch "..TexCmd("nameref", cityLabel)..".")
			end
			table.sort(sortedNPCs[regionLabel][cityLabel]["labels"])
			for key3, npcLabel in pairs(sortedNPCs[regionLabel][cityLabel]["labels"]) do
				local npc = Entities[npcLabel]
				tex.print(TexCmd("subsubsection", npc["name"], npc["shortname"]))
				tex.print(TexCmd("label",npcLabel))
				tex.print(SpeciesAndAgeString(npc))
				tex.print(descriptorsString(npc))
			end
		end
	end
end

local function addPrimaryPlaceNPCsToRefs()
	for key, ref in pairs(PrimaryRefs) do
		if Entities[ref] ~= nil then
			local npcsHere = Entities[ref]["NPCs"]
			if npcsHere ~= nil then
				for label, npc in pairs(npcsHere) do
					AddRef(label, PrimaryRefs)
				end
			end
		end
	end
end

local function addPrimaryPlaceParentsToRefs()
	for label, entry in pairs(Entities) do
		if IsIn(label, PrimaryRefs) then
			while label ~= nil do
				AddRef(label, PrimaryRefs)
				label = Entities[label]["parent"]
			end
		end
	end
end

local function scanContentForSecondaryRefs(list)
	for label, entry in pairs(list) do
		if IsIn(label, PrimaryRefs) then
			for key, content in pairs(entry) do
				if type(content) == "string" then
					ScanForSecondaryRefs(content)
				elseif type(content) == "table" then
					for key2, subcontent in pairs(content) do
						if type(subcontent) == "string" then
							ScanForSecondaryRefs(subcontent)
						end
					end
				end
			end
		end
	end
end

local function deleteUnused(list)
	for label, entry in pairs(list) do
		if not IsIn(label, PrimaryRefs) then
			if IsIn(label, SecondaryRefs) then
				list[label]["parent"] = OnlyMentioned
				list[label]["location"] = OnlyMentioned
			else
				list[label] = nil
			end
		end
	end
end

local function addPrimaryNPCLocationsToRefs()
	for label, npc in pairs(Entities) do
		if IsIn(label, PrimaryRefs) then
			local location = npc["location"]
			if location ~= nil then
				AddRef(location, PrimaryRefs)
			end
		end
	end
end

local function addHistoryDescriptors()
	for key, label in pairs(PrimaryRefs) do
		local history = Histories[label]
		if history ~= nil then
			AddDescriptor(label, HistoryCaption, history)
			ScanHistoryForSecondaryRefs(history)
		end
	end
end

local function complementRefs()
	addPrimaryPlaceNPCsToRefs()
	addPrimaryNPCLocationsToRefs()
	addPrimaryPlaceParentsToRefs()
	addHistoryDescriptors()
	scanContentForSecondaryRefs(Entities)
	deleteUnused(Entities)
end


local function createNPCs()
	tex.print(TexCmd("twocolumn"))
	tex.print(TexCmd("chapter","NPCs"))
	tex.print(TexCmd("section","Alle NPCs, alphabetisch sortiert"))
	local npcs = getEntitiesIf(isChar)
	tex.print(listAllFromMap(npcs))
	tex.print(TexCmd("onecolumn"))
	
	createNPCsSortedByPlace()
end

local function createGeographyLayer(currentDepth, parent)
	if currentDepth > #PlaceDepths then
		return
	end
	local placeLabels = {}
	for label,place in pairs(Entities) do
		if place["type"] == PlaceDepths[currentDepth][1] or parent == OnlyMentioned then
			if parent == nil or place["parent"] == parent then
				placeLabels[#placeLabels+1] = label
			end
		end
	end
	table.sort(placeLabels)

	for key,label in pairs(placeLabels) do
		local place = Entities[label]
		local str = ""
		local docStructure = PlaceDepths[currentDepth][2]
		if place["parent"] ~= nil and place["parent"] == OnlyMentioned then
			docStructure = "paragraph"
		end
		str = str..TexCmd(docStructure, place["name"], place["shortname"])
		str = str..TexCmd("label", label)
		str = str..descriptorsString(place)
		tex.print(str)
		createGeographyLayer(currentDepth + 1, label)
	end
end

local function createGeography()
	tex.print(TexCmd("twocolumn"))
	tex.print(TexCmd("chapter","Orte"))
	tex.print(TexCmd("section","Alle Orte, alphabetisch sortiert"))
	local places = getEntitiesIf(isPlace)
	tex.print(listAllFromMap(places))
	tex.print(TexCmd("onecolumn"))
	
	tex.print(TexCmd("section", "Yestaiel, die Welt", "Yestaiel"))
	tex.print(TexCmd("label", "yestaiel"))
	tex.print(TexCmd("input", "../shared/geography/yestaiel.tex"))
	
	createGeographyLayer(1)
end

function AutomatedChapters()
	addNPCsToPlaces()
	complementRefs()
	createNPCs()
	createGeography()
end

function AddAllRefsToPrimary()
	for label, elem in pairs(Entities) do
		AddRef(label, PrimaryRefs)
	end
end
