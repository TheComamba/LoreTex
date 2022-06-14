npcs = {}
places = {}
currentLabel = ""
placeTypes = {"continent", "region", "city"}
placeDepths = {{placeTypes[1], "section"},
				{placeTypes[2],"subsection"},
				{placeTypes[3],"subsubsection"}}
protectedDescriptors = {"name", "shortname", "type", "parent", "location", "born", "died", "species", "gender"}
onlyMentioned = "zzz-nur-erwähnt"
heimatlos = "zzz-heimatlos"
addRef(onlyMentioned,primaryRefs)
places[onlyMentioned] = {}
places[onlyMentioned]["name"] = "Nur erwähnt"
places[onlyMentioned]["type"] = placeTypes[1]

function addDescriptor(label, descriptor, description)
	if isStringEmpty(label) then
		return
	elseif isStringEmpty(descriptor) then
		return
	elseif isStringEmpty(description) then
		return
	end
	
	if descriptor == "type" then
		if isIn(description, placeTypes) then
			places[label] = {}
		elseif description == "npc" then
			npcs[label] = {}
		end
	end
	
	if places[label] ~= nil then
		places[label][descriptor] = description
	elseif npcs[label] ~= nil then
		npcs[label][descriptor] = description
	end
end

function setLocation(label, location)
	if npcs[label] == nil then
		return
	end
	
	if location ~= nil then
		npcs[label]["location"] = location
	elseif currentCity ~= "" then
		npcs[label]["location"] = currentCity
	elseif currentRegion ~= "" then
		npcs[label]["location"] = currentRegion
	elseif currentContinent ~= "" then
		npcs[label]["location"] = currentContinent
	end
end

function listAllFromMap(listOfThings)
	local allLabels = {}
	for label,elem in pairs(listOfThings) do
		allLabels[#allLabels+1] = label
	end
	return listAll(allLabels, namerefString)
end

function addNPCsToPlaces()
	for label,npc in pairs(npcs) do
		local location = npc["location"]
		if location ~= nil and places[location] ~= nil then
			if places[location]["NPCs"] == nil then
				places[location]["NPCs"] = {}
			end
			places[location]["NPCs"][label] = npc["name"]
		end
	end
end

function descriptorsString(entity)
	local str = ""
	if entity["parent"] ~= nil and entity["parent"] == onlyMentioned then
		return texCmd("hspace","1cm")
	elseif entity["location"] ~= nil and entity["location"] == onlyMentioned then
		return texCmd("hspace","1cm")
	end
	
	str = str..speciesAndAgeString(entity)..[[
	
	]]
	
	local descriptorsList = {}
	for descriptor, description in pairs(entity) do
		if not isIn(descriptor, protectedDescriptors) then
			descriptorsList[#descriptorsList+1] = descriptor
		end
	end
	table.sort(descriptorsList)
	for key, descriptor in pairs(descriptorsList) do
		str = str..texCmd("paragraph", descriptor)
		if descriptor == historyCaption then
			str = str..listHistory(entity[descriptor])
		elseif type(entity[descriptor]) == "string" then
			str = str..entity[descriptor]
		elseif type(entity[descriptor]) == "table" then
			str = str..listAllFromMap(entity[descriptor])
		end
	end
	return str
end

function createNPCsSortedByPlace()
	sortedNPCs = {}
	sortedNPCs["labels"] = {}
	for label, npc in pairs(npcs) do
		local city = npc["location"]
		local region = nil
		
		if city == nil then
			city = heimatlos
			region = "andere"
		elseif places[city] == nil then
			city = "notfound"
			region = "andere"
		elseif places[city]["type"] == "region" then
			region = city
			city = heimatlos
		elseif places[city]["parent"] == nil then
			region = "andere"
		else
			region =  places[city]["parent"]
		end
		
		if not isIn(region, sortedNPCs["labels"]) then
			sortedNPCs["labels"][#(sortedNPCs["labels"])+1] = region
			sortedNPCs[region] = {}
			sortedNPCs[region]["labels"] = {}
		end
		if not isIn(city, sortedNPCs[region]["labels"]) then
			sortedNPCs[region]["labels"][#(sortedNPCs[region]["labels"])+1] = city
			sortedNPCs[region][city] = {}
			sortedNPCs[region][city]["labels"] = {}
		end
		sortedNPCs[region][city]["labels"][#(sortedNPCs[region][city]["labels"])+1] = label
	end
	
	table.sort(sortedNPCs["labels"])
	for key1, region in pairs(sortedNPCs["labels"]) do
		local regionName = "Woanders"
		if places[region] ~= nil then
			if places[region]["shortname"] then
				regionName = places[region]["shortname"]
			else
				regionName = places[region]["name"]
			end
		end
		tex.print(texCmd("section","NPCs in "..regionName))
		table.sort(sortedNPCs[region]["labels"])
		for key2, city in pairs(sortedNPCs[region]["labels"]) do
			local cityName = "NOT FOUND"
			if places[city] ~= nil then
				if places[city]["shortname"] then
					cityName = places[city]["shortname"]
				else
					cityName = places[city]["name"]
				end
			elseif city == heimatlos then
				cityName = "Heimatlos"
			end
			tex.print(texCmd("subsection", "NPCs in "..cityName))
			if isIn(city, primaryRefs) or isIn(city, secondaryRefs) then
				tex.print("Siehe auch "..texCmd("nameref", city))
			end
			table.sort(sortedNPCs[region][city]["labels"])
			for key3, npcLabel in pairs(sortedNPCs[region][city]["labels"]) do
				local npc = npcs[npcLabel]
				tex.print(texCmd("subsubsection", npc["name"], npc["shortname"]))
				tex.print(texCmd("label",npcLabel))
				tex.print(descriptorsString(npc))
			end
		end
	end
end

function addPrimaryPlaceNPCsToRefs()
	for key, ref in pairs(primaryRefs) do
		if places[ref] ~= nil then
			local npcsHere = places[ref]["NPCs"]
			if npcsHere ~= nil then
				for label, npc in pairs(npcsHere) do
					addRef(label, primaryRefs)
				end
			end
		end
	end
end

function addPrimaryPlaceParentsToRefs()
	for label, entry in pairs(places) do
		if isIn(label, primaryRefs) then
			while label ~= nil do
				addRef(label, primaryRefs)
				label = places[label]["parent"]
			end
		end
	end
end

function scanContentForSecondaryRefs(list)
	for label, entry in pairs(list) do
		if isIn(label, primaryRefs) then
			for key, content in pairs(entry) do
				if type(content) == "string" then
					scanForSecondaryRefs(content)
				elseif type(content) == "table" then
					for key2, subcontent in pairs(content) do
						if type(subcontent) == "string" then
							scanForSecondaryRefs(subcontent)
						end
					end
				end
			end
		end
	end
end

function deleteUnused(list)
	for label, entry in pairs(list) do
		if not isIn(label, primaryRefs) then
			if isIn(label, secondaryRefs) then
				list[label]["parent"] = onlyMentioned
				list[label]["location"] = onlyMentioned
			else
				list[label] = nil
			end
		end
	end
end

function addPrimaryNPCLocationsToRefs()
	for label, npc in pairs(npcs) do
		if isIn(label, primaryRefs) then
			local location = npc["location"]
			if location ~= nil then
				addRef(location, primaryRefs)
			end
		end
	end
end

function complementRefs()
	addPrimaryPlaceNPCsToRefs()
	addPrimaryNPCLocationsToRefs()
	addPrimaryPlaceParentsToRefs(places)
	addHistoryDescriptors()
	scanContentForSecondaryRefs(npcs)
	scanContentForSecondaryRefs(places)
	deleteUnused(npcs)
	deleteUnused(places)
end

function addHistoryDescriptors()
	for key, label in pairs(primaryRefs) do
		local history = histories[label]
		if history ~= nil then
			addDescriptor(label, historyCaption, history)
			scanHistoryForSecondaryRefs(history)
		end
	end
end

function createNPCs()
	tex.print(texCmd("twocolumn"))
	tex.print(texCmd("chapter","NPCs"))
	tex.print(texCmd("section","Alle NPCs, alphabetisch sortiert"))
	tex.print(listAllFromMap(npcs))
	tex.print(texCmd("onecolumn"))
	
	createNPCsSortedByPlace()
end

function createGeographyLayer(currentDepth, parent)
	if currentDepth > #placeDepths then
		return
	end
	placeLabels = {}
	for label,place in pairs(places) do
		if place["type"] == placeDepths[currentDepth][1] or parent == onlyMentioned then
			if parent == nil or place["parent"] == parent then
				placeLabels[#placeLabels+1] = label
			end
		end
	end
	table.sort(placeLabels)

	for key,label in pairs(placeLabels) do
		local place = places[label]
		local str = ""
		local docStructure = placeDepths[currentDepth][2]
		if place["parent"] ~= nil and place["parent"] == onlyMentioned then
			docStructure = "paragraph"
		end
		str = str..texCmd(docStructure, place["name"], place["shortname"])
		str = str..texCmd("label", label)
		str = str..descriptorsString(place)
		tex.print(str)
		createGeographyLayer(currentDepth + 1, label)
	end
end

function createGeography()
	tex.print(texCmd("twocolumn"))
	tex.print(texCmd("chapter","Orte"))
	tex.print(texCmd("section","Alle Orte, alphabetisch sortiert"))
	tex.print(listAllFromMap(places))
	tex.print(texCmd("onecolumn"))
	
	tex.print(texCmd("section", "Yestaiel, die Welt", "Yestaiel"))
	tex.print(texCmd("label", "yestaiel"))
	tex.print(texCmd("input", "../shared/geography/yestaiel.tex"))
	
	createGeographyLayer(1)
end

function automatedChapters()
	addNPCsToPlaces()
	complementRefs()
	createNPCs()
	createGeography()
end

function addAllRefsToPrimary()
	for key, list in pairs({npcs,places}) do
		for label, elem in pairs(list) do
			addRef(label, primaryRefs)
		end
	end
end