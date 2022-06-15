Species = {}

Species["dragon"] = {}
Species["dragon"]["ageExponent"] = 2.6
Species["dragon"]["nominative"] = "Drache"
Species["dragon"]["genitive"] = "Drachen"

Species["dwarf"] = {}
Species["dwarf"]["ageExponent"] = 1.9
Species["dwarf"]["nominative"] = "Zwerg"
Species["dwarf"]["genitive"] = "Zwergen"

Species["dragenborn"] = {}
Species["dragenborn"]["ageExponent"] = 1
Species["dragenborn"]["nominative"] = "Drachenspross"
Species["dragenborn"]["genitive"] = "Drachenspross"

Species["elf"] = {}
Species["elf"]["ageExponent"] = 2.2
Species["elf"]["nominative"] = "Elb"
Species["elf"]["genitive"] = "Elben"

Species["firbolg"] = {}
Species["firbolg"]["ageExponent"] = 1.81
Species["firbolg"]["nominative"] = "Firbolg"
Species["firbolg"]["genitive"] = "Firbolg"

Species["genasi-fire"] = {}
Species["genasi-fire"]["ageExponent"] = 0.9
Species["genasi-fire"]["nominative"] = "Feuergenasi"
Species["genasi-fire"]["genitive"] = "Feuergenasi"

Species["genasi-water"] = {}
Species["genasi-water"]["ageExponent"] = 1.05
Species["genasi-water"]["nominative"] = "Wassergenasi"
Species["genasi-water"]["genitive"] = "Wassergenasi"

Species["genasi-earth"] = {}
Species["genasi-earth"]["ageExponent"] = 1.1
Species["genasi-earth"]["nominative"] = "Erdgenasi"
Species["genasi-earth"]["genitive"] = "Erdgenasi"

Species["genasi-air"] = {}
Species["genasi-air"]["ageExponent"] = 0.95
Species["genasi-air"]["nominative"] = "Luftgenasi"
Species["genasi-air"]["genitive"] = "Luftgenasi"

Species["giant"] = {}
Species["giant"]["ageExponent"] = 2
Species["giant"]["nominative"] = "Riese"
Species["giant"]["genitive"] = "Riesen"

Species["gnoll"] = {}
Species["gnoll"]["ageExponent"] = 0.6
Species["gnoll"]["nominative"] = "Gnoll"
Species["gnoll"]["genitive"] = "Gnoll"

Species["gnome"] = {}
Species["gnome"]["ageExponent"] = 1.79
Species["gnome"]["nominative"] = "Gnom"
Species["gnome"]["genitive"] = "Gnomen"

Species["goblin"] = {}
Species["goblin"]["ageExponent"] = 0.78
Species["goblin"]["nominative"] = "Goblin"
Species["goblin"]["genitive"] = "Goblin"

Species["goliath"] = {}
Species["goliath"]["ageExponent"] = 1
Species["goliath"]["nominative"] = "Goliath"
Species["goliath"]["genitive"] = "Goliath"

Species["halfdragon"] = {}
Species["halfdragon"]["ageExponent"] = 1.85
Species["halfdragon"]["nominative"] = "Halbdrache"
Species["halfdragon"]["genitive"] = "Halbdrachen"

Species["halfelf"] = {}
Species["halfelf"]["ageExponent"] = 1.55
Species["halfelf"]["nominative"] = "Halbelb"
Species["halfelf"]["genitive"] = "Halbelben"

Species["halfling"] = {}
Species["halfling"]["ageExponent"] = 1.5
Species["halfling"]["nominative"] = "Halbling"
Species["halfling"]["genitive"] = "Halbling"

Species["halforc"] = {}
Species["halforc"]["ageExponent"] = 0.95
Species["halforc"]["nominative"] = "Halbork"
Species["halforc"]["genitive"] = "Halork"

Species["halfsphinx"] = {}
Species["halfsphinx"]["ageExponent"] = 1.7
Species["halfsphinx"]["nominative"] = "Halbsphinx"
Species["halfsphinx"]["genitive"] = "Halbsphinxen"

Species["human"] = {}
Species["human"]["ageExponent"] = 1
Species["human"]["nominative"] = "Mensch"
Species["human"]["genitive"] = "Menschen"

Species["kenku"] = {}
Species["kenku"]["ageExponent"] = 0.83
Species["kenku"]["nominative"] = "Kenku"
Species["kenku"]["genitive"] = "Kenku"

Species["kobold"] = {}
Species["kobold"]["ageExponent"] = 1.2
Species["kobold"]["nominative"] = "Kobold"
Species["kobold"]["genitive"] = "Kobold"

Species["merperson"] = {}
Species["merperson"]["ageExponent"] = 1
Species["merperson"]["nominative"] = "Meermensch"
Species["merperson"]["genitive"] = "Meer"

Species["orc"] = {}
Species["orc"]["ageExponent"] = 0.8
Species["orc"]["nominative"] = "Ork"
Species["orc"]["genitive"] = "Ork"

Species["shai"] = {}
Species["shai"]["ageExponent"] = 1.75
Species["shai"]["nominative"] = "Sandelb"
Species["shai"]["genitive"] = "Sandelben"

Species["tabaxi"] = {}
Species["tabaxi"]["ageExponent"] = 1
Species["tabaxi"]["nominative"] = "Tabaxi"
Species["tabaxi"]["genitive"] = "Tabaxi"

Species["tiefling"] = {}
Species["tiefling"]["ageExponent"] = 1
Species["tiefling"]["nominative"] = "Tiefling"
Species["tiefling"]["genitive"] = "Tiefling"

Species["triton"] = {}
Species["triton"]["ageExponent"] = 1.45
Species["triton"]["nominative"] = "Triton"
Species["triton"]["genitive"] = "Triton"

Species["yuan-ti"] = {}
Species["yuan-ti"]["ageExponent"] = 1
Species["yuan-ti"]["nominative"] = "Yuan-Ti"
Species["yuan-ti"]["genitive"] = "Yuan-Ti"

function SpeciesToHuman(years, speciesName)
	if speciesName == nil then
		return -1
	end
	if years <= 10 then
		return years
	else
		local exponent = Species[speciesName]["ageExponent"]
		return math.round(10*(years/10)^exponent)
	end
end

function HumanToSpecies(years, speciesName)
	if speciesName == nil then
		return -1
	end
	if years <= 10 then
		return years
	else
		local exponent = Species[speciesName]["ageExponent"]
		return math.round((years/10)^(1/exponent) * 10)
	end
end

function ConvertAge(age, speciesName)
	if Species[speciesName] == nil then
		tex.print("UNKNOWN SPECIES OF AGE "..age)
	end
	local speciesAge = SpeciesToHuman(age, speciesName)
	local gen = Species[speciesName]["genitive"]
	tex.print(speciesAge.." Jahre ("..age.." "..gen.."jahre)")
end

function SpeciesAndAgeString(npc, year)
	local str = ""

	local speciesName = npc["species"]
	local gender = npc["gender"]
	if speciesName ~= nil and Species[speciesName] ~= nil then
		if gender ~= nil then
			local gen = Species[speciesName]["genitive"]
			if gender == "male" then
				str = str..gen.."-Mann"
			elseif gender == "female" then
				str = str..gen.."-Frau"
			else
				str = str..gen.."-Person"
			end
		else
			str = str..Species[speciesName]["nominative"]
		end
	end
	
	local born = npc["born"]
	if born ~= nil then
		born = tonumber(born)
		if str ~= "" then
			str = str..", "
		end
		if year == nil then
			year = CurrentYearVin
		end
		local age = CurrentYearVin - born
		local died = npc["died"]
		if died ~= nil then
			died = tonumber(died)
			if died <= CurrentYearVin then
				age = died - born
				str = str.."wurde "
			end
		end
		str = str..age.." Jahre "
		if speciesName ~= nil and Species[speciesName] ~= nil and Species[speciesName]["ageExponent"] ~= 1 then
			str = str.."("..HumanToSpecies(age, speciesName).." "
			str = str..Species[speciesName]["genitive"].."jahre) "
		end
		str = str.."alt."
	end
	
	return str
end


function AgeTable()
	tex.print("Bis zum 10. Lebensjahr altern alle Species gleich schnell. Die durchschnittliche Lebenserwartung sind 60 Jahre.")
	tex.print("")
	local speciesNames = {}
	for speciesName, something in pairs(Species) do
		speciesNames[#speciesNames + 1] = speciesName
	end
	table.sort(speciesNames)
	local str = TexCmd("begin", "tabular")
	str = str..[[{c|ccccc}
	Species& jugendlich& jung& mittel& alt& sehr alt\\]]
	str = str..TexCmd("hline").." "
	for key, speciesName in pairs(speciesNames) do
		str = str..Species[speciesName]["nominative"]..[[&]]
		for key2, age in pairs({15, 25, 40,60,80}) do
			if key2 ~= 1 then
				str = str..[[&]]
			end
			str = str..SpeciesToHuman(age, speciesName).." a"
		end
		str = str..[[\\]]
	end
	str = str..TexCmd("end", "tabular")
	tex.print(str)
end