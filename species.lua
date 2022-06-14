species = {}

species["dragon"] = {}
species["dragon"]["ageExponent"] = 2.6
species["dragon"]["nominative"] = "Drache"
species["dragon"]["genitive"] = "Drachen"

species["dwarf"] = {}
species["dwarf"]["ageExponent"] = 1.9
species["dwarf"]["nominative"] = "Zwerg"
species["dwarf"]["genitive"] = "Zwergen"

species["dragenborn"] = {}
species["dragenborn"]["ageExponent"] = 1
species["dragenborn"]["nominative"] = "Drachenspross"
species["dragenborn"]["genitive"] = "Drachenspross"

species["elf"] = {}
species["elf"]["ageExponent"] = 2.2
species["elf"]["nominative"] = "Elb"
species["elf"]["genitive"] = "Elben"

species["firbolg"] = {}
species["firbolg"]["ageExponent"] = 1.81
species["firbolg"]["nominative"] = "Firbolg"
species["firbolg"]["genitive"] = "Firbolg"

species["giant"] = {}
species["giant"]["ageExponent"] = 2
species["giant"]["nominative"] = "Riese"
species["giant"]["genitive"] = "Riesen"

species["gnome"] = {}
species["gnome"]["ageExponent"] = 1.79
species["gnome"]["nominative"] = "Gnom"
species["gnome"]["genitive"] = "Gnomen"

species["goblin"] = {}
species["goblin"]["ageExponent"] = 0.78
species["goblin"]["nominative"] = "Goblin"
species["goblin"]["genitive"] = "Goblin"

species["goliath"] = {}
species["goliath"]["ageExponent"] = 1
species["goliath"]["nominative"] = "Goliath"
species["goliath"]["genitive"] = "Goliath"

species["gnoll"] = {}
species["gnoll"]["ageExponent"] = 0.6
species["gnoll"]["nominative"] = "Gnoll"
species["gnoll"]["genitive"] = "Gnoll"

species["halfdragon"] = {}
species["halfdragon"]["ageExponent"] = 1.85
species["halfdragon"]["nominative"] = "Halbdrache"
species["halfdragon"]["genitive"] = "Halbdrachen"

species["halfelf"] = {}
species["halfelf"]["ageExponent"] = 1.55
species["halfelf"]["nominative"] = "Halbelb"
species["halfelf"]["genitive"] = "Halbelben"

species["halfling"] = {}
species["halfling"]["ageExponent"] = 1.5
species["halfling"]["nominative"] = "Halbling"
species["halfling"]["genitive"] = "Halbling"

species["halforc"] = {}
species["halforc"]["ageExponent"] = 0.95
species["halforc"]["nominative"] = "Halbork"
species["halforc"]["genitive"] = "Halork"

species["halfsphinx"] = {}
species["halfsphinx"]["ageExponent"] = 1.7
species["halfsphinx"]["nominative"] = "Halbsphinx"
species["halfsphinx"]["genitive"] = "Halbsphinxen"

species["human"] = {}
species["human"]["ageExponent"] = 1
species["human"]["nominative"] = "Mensch"
species["human"]["genitive"] = "Menschen"

species["kenku"] = {}
species["kenku"]["ageExponent"] = 0.83
species["kenku"]["nominative"] = "Kenku"
species["kenku"]["genitive"] = "Kenku"

species["kobold"] = {}
species["kobold"]["ageExponent"] = 1.1
species["kobold"]["nominative"] = "Kobold"
species["kobold"]["genitive"] = "Kobold"

species["merperson"] = {}
species["merperson"]["ageExponent"] = 1
species["merperson"]["nominative"] = "Meermensch"
species["merperson"]["genitive"] = "Meer"

species["orc"] = {}
species["orc"]["ageExponent"] = 0.8
species["orc"]["nominative"] = "Ork"
species["orc"]["genitive"] = "Ork"

species["shai"] = {}
species["shai"]["ageExponent"] = 1.75
species["shai"]["nominative"] = "Sandelb"
species["shai"]["genitive"] = "Sandelben"

species["tabaxi"] = {}
species["tabaxi"]["ageExponent"] = 1
species["tabaxi"]["nominative"] = "Tabaxi"
species["tabaxi"]["genitive"] = "Tabaxi"

species["tiefling"] = {}
species["tiefling"]["ageExponent"] = 1
species["tiefling"]["nominative"] = "Tiefling"
species["tiefling"]["genitive"] = "Tiefling"

species["triton"] = {}
species["triton"]["ageExponent"] = 1.45
species["triton"]["nominative"] = "Triton"
species["triton"]["genitive"] = "Triton"

species["yuan-ti"] = {}
species["yuan-ti"]["ageExponent"] = 1
species["yuan-ti"]["nominative"] = "Yuan-Ti"
species["yuan-ti"]["genitive"] = "Yuan-Ti"

function speciesToHuman(years, speciesName)
	if speciesName == nil then
		return -1
	end
	if years <= 10 then
		return years
	else
		local exponent = species[speciesName]["ageExponent"]
		return math.round(10*(years/10)^exponent)
	end
end

function humanToSpecies(years, speciesName)
	if speciesName == nil then
		return -1
	end
	if years <= 10 then
		return years
	else
		local exponent = species[speciesName]["ageExponent"]
		return math.round((years/10)^(1/exponent) * 10)
	end
end

function convertAge(age, speciesName)
	if species[speciesName] == nil then
		tex.print("UNKNOWN SPECIES OF AGE "..age)
	end
	local speciesAge = speciesToHuman(age, speciesName)
	local gen = species[speciesName]["genitive"]
	tex.print(speciesAge.." Jahre ("..age.." "..gen.."jahre)")
end

function speciesAndAgeString(npc, year)
	local str = ""

	local speciesName = npc["species"]
	local gender = npc["gender"]
	if speciesName ~= nil and species[speciesName] ~= nil then
		if gender ~= nil then
			local gen = species[speciesName]["genitive"]
			if gender == "male" then
				str = str..gen.."-Mann"
			elseif gender == "female" then
				str = str..gen.."-Frau"
			else
				str = str..gen.."-Person"
			end
		else
			str = str..species[speciesName]["nominative"]
		end
	end
	
	local born = npc["born"]
	if born ~= nil then
		born = tonumber(born)
		if str ~= "" then
			str = str..", "
		end
		if year == nil then
			year = currentYearVin
		end
		local age = currentYearVin - born
		local died = npc["died"]
		if died ~= nil then
			died = tonumber(died)
			if died <= currentYearVin then
				age = died - born
				str = str.."wurde "
			end
		end
		str = str..age.." Jahre "
		if speciesName ~= nil and species[speciesName] ~= nil and species[speciesName]["ageExponent"] ~= 1 then
			str = str.."("..humanToSpecies(age, speciesName).." "
			str = str..species[speciesName]["genitive"].."jahre) "
		end
		str = str.."alt."
	end
	
	return str
end


function ageTable()
	tex.print("Bis zum 10. Lebensjahr altern alle Species gleich schnell. Die durchschnittliche Lebenserwartung sind 60 Jahre.")
	tex.print("")
	local speciesNames = {}
	for speciesName, something in pairs(species) do
		speciesNames[#speciesNames + 1] = speciesName
	end
	table.sort(speciesNames)
	local str = texCmd("begin", "tabular")
	str = str..[[{c|ccccc}
	Species& jugendlich& jung& mittel& alt& sehr alt\\]]
	str = str..texCmd("hline").." "
	for key, speciesName in pairs(speciesNames) do
		str = str..species[speciesName]["nominative"]..[[&]]
		for key2, age in pairs({15, 25, 40,60,80}) do
			if key2 ~= 1 then
				str = str..[[&]]
			end
			str = str..speciesToHuman(age, speciesName).." a"
		end
		str = str..[[\\]]
	end
	str = str..texCmd("end", "tabular")
	tex.print(str)
end