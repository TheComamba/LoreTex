Npcs = {}
Places = {}
CurrentLabel = ""
PlaceTypes = {"continent", "region", "city"}
PlaceDepths = {{PlaceTypes[1], "section"},
				{PlaceTypes[2],"subsection"},
				{PlaceTypes[3],"subsubsection"}}
ProtectedDescriptors = {"name", "shortname", "type", "parent", "location", "born", "died", "species", "gender"}
OnlyMentioned = "zzz-nur-erwähnt"
Heimatlos = "zzz-heimatlos"
AddRef(OnlyMentioned,PrimaryRefs)
Places[OnlyMentioned] = {}
Places[OnlyMentioned]["name"] = "Nur erwähnt"
Places[OnlyMentioned]["type"] = PlaceTypes[1]

function AddDescriptor(label, descriptor, description)
	if IsStringEmpty(label) then
		return
	elseif IsStringEmpty(descriptor) then
		return
	elseif IsStringEmpty(description) then
		return
	end
	
	if descriptor == "type" then
		if IsIn(description, PlaceTypes) then
			Places[label] = {}
		elseif description == "npc" then
			Npcs[label] = {}
		end
	end
	
	if Places[label] ~= nil then
		Places[label][descriptor] = description
	elseif Npcs[label] ~= nil then
		Npcs[label][descriptor] = description
	end
end

function SetLocation(label, location)
	if Npcs[label] == nil then
		return
	end
	
	if location ~= nil then
		Npcs[label]["location"] = location
	elseif CurrentCity ~= "" then
		Npcs[label]["location"] = CurrentCity
	elseif CurrentRegion ~= "" then
		Npcs[label]["location"] = CurrentRegion
	elseif CurrentContinent ~= "" then
		Npcs[label]["location"] = CurrentContinent
	end
end

function ListAllFromMap(listOfThings)
	local allLabels = {}
	for label,elem in pairs(listOfThings) do
		allLabels[#allLabels+1] = label
	end
	return ListAll(allLabels, NamerefString)
end

function AddNPCsToPlaces()
	for label,npc in pairs(Npcs) do
		local location = npc["location"]
		if location ~= nil and Places[location] ~= nil then
			if Places[location]["NPCs"] == nil then
				Places[location]["NPCs"] = {}
			end
			Places[location]["NPCs"][label] = npc["name"]
		end
	end
end

function DescriptorsString(entity)
	local str = ""
	if entity["parent"] ~= nil and entity["parent"] == OnlyMentioned then
		return TexCmd("hspace","1cm")
	elseif entity["location"] ~= nil and entity["location"] == OnlyMentioned then
		return TexCmd("hspace","1cm")
	end
	
	str = str..SpeciesAndAgeString(entity)..[[
	
	]]
	
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
			str = str..ListAllFromMap(entity[descriptor])
		end
	end
	return str
end

function CreateNPCsSortedByPlace()
	local sortedNPCs = {}
	sortedNPCs["labels"] = {}
	for label, npc in pairs(Npcs) do
		local city = npc["location"]
		local region = nil
		
		if city == nil then
			city = Heimatlos
			region = "andere"
		elseif Places[city] == nil then
			city = "notfound"
			region = "andere"
		elseif Places[city]["type"] == "region" then
			region = city
			city = Heimatlos
		elseif Places[city]["parent"] == nil then
			region = "andere"
		else
			region =  Places[city]["parent"]
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
	
	table.sort(sortedNPCs["labels"])
	for key1, region in pairs(sortedNPCs["labels"]) do
		local regionName = "Woanders"
		if Places[region] ~= nil then
			if Places[region]["shortname"] then
				regionName = Places[region]["shortname"]
			else
				regionName = Places[region]["name"]
			end
		end
		tex.print(TexCmd("section","NPCs in "..regionName))
		table.sort(sortedNPCs[region]["labels"])
		for key2, city in pairs(sortedNPCs[region]["labels"]) do
			local cityName = "NOT FOUND"
			if Places[city] ~= nil then
				if Places[city]["shortname"] then
					cityName = Places[city]["shortname"]
				else
					cityName = Places[city]["name"]
				end
			elseif city == Heimatlos then
				cityName = "Heimatlos"
			end
			tex.print(TexCmd("subsection", "NPCs in "..cityName))
			if IsIn(city, PrimaryRefs) or IsIn(city, SecondaryRefs) then
				tex.print("Siehe auch "..TexCmd("nameref", city))
			end
			table.sort(sortedNPCs[region][city]["labels"])
			for key3, npcLabel in pairs(sortedNPCs[region][city]["labels"]) do
				local npc = Npcs[npcLabel]
				tex.print(TexCmd("subsubsection", npc["name"], npc["shortname"]))
				tex.print(TexCmd("label",npcLabel))
				tex.print(DescriptorsString(npc))
			end
		end
	end
end

function AddPrimaryPlaceNPCsToRefs()
	for key, ref in pairs(PrimaryRefs) do
		if Places[ref] ~= nil then
			local npcsHere = Places[ref]["NPCs"]
			if npcsHere ~= nil then
				for label, npc in pairs(npcsHere) do
					AddRef(label, PrimaryRefs)
				end
			end
		end
	end
end

function AddPrimaryPlaceParentsToRefs()
	for label, entry in pairs(Places) do
		if IsIn(label, PrimaryRefs) then
			while label ~= nil do
				AddRef(label, PrimaryRefs)
				label = Places[label]["parent"]
			end
		end
	end
end

function ScanContentForSecondaryRefs(list)
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

function DeleteUnused(list)
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

function AddPrimaryNPCLocationsToRefs()
	for label, npc in pairs(Npcs) do
		if IsIn(label, PrimaryRefs) then
			local location = npc["location"]
			if location ~= nil then
				AddRef(location, PrimaryRefs)
			end
		end
	end
end

function ComplementRefs()
	AddPrimaryPlaceNPCsToRefs()
	AddPrimaryNPCLocationsToRefs()
	AddPrimaryPlaceParentsToRefs()
	AddHistoryDescriptors()
	ScanContentForSecondaryRefs(Npcs)
	ScanContentForSecondaryRefs(Places)
	DeleteUnused(Npcs)
	DeleteUnused(Places)
end

function AddHistoryDescriptors()
	for key, label in pairs(PrimaryRefs) do
		local history = Histories[label]
		if history ~= nil then
			AddDescriptor(label, HistoryCaption, history)
			ScanHistoryForSecondaryRefs(history)
		end
	end
end

function CreateNPCs()
	tex.print(TexCmd("twocolumn"))
	tex.print(TexCmd("chapter","NPCs"))
	tex.print(TexCmd("section","Alle NPCs, alphabetisch sortiert"))
	tex.print(ListAllFromMap(Npcs))
	tex.print(TexCmd("onecolumn"))
	
	CreateNPCsSortedByPlace()
end

function CreateGeographyLayer(currentDepth, parent)
	if currentDepth > #PlaceDepths then
		return
	end
	local placeLabels = {}
	for label,place in pairs(Places) do
		if place["type"] == PlaceDepths[currentDepth][1] or parent == OnlyMentioned then
			if parent == nil or place["parent"] == parent then
				placeLabels[#placeLabels+1] = label
			end
		end
	end
	table.sort(placeLabels)

	for key,label in pairs(placeLabels) do
		local place = Places[label]
		local str = ""
		local docStructure = PlaceDepths[currentDepth][2]
		if place["parent"] ~= nil and place["parent"] == OnlyMentioned then
			docStructure = "paragraph"
		end
		str = str..TexCmd(docStructure, place["name"], place["shortname"])
		str = str..TexCmd("label", label)
		str = str..DescriptorsString(place)
		tex.print(str)
		CreateGeographyLayer(currentDepth + 1, label)
	end
end

function CreateGeography()
	tex.print(TexCmd("twocolumn"))
	tex.print(TexCmd("chapter","Orte"))
	tex.print(TexCmd("section","Alle Orte, alphabetisch sortiert"))
	tex.print(ListAllFromMap(Places))
	tex.print(TexCmd("onecolumn"))
	
	tex.print(TexCmd("section", "Yestaiel, die Welt", "Yestaiel"))
	tex.print(TexCmd("label", "yestaiel"))
	tex.print(TexCmd("input", "../shared/geography/yestaiel.tex"))
	
	CreateGeographyLayer(1)
end

function AutomatedChapters()
	AddNPCsToPlaces()
	ComplementRefs()
	CreateNPCs()
	CreateGeography()
end

function AddAllRefsToPrimary()
	for key, list in pairs({Npcs,Places}) do
		for label, elem in pairs(list) do
			AddRef(label, PrimaryRefs)
		end
	end
end