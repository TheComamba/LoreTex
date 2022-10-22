Append(ProtectedDescriptors, { "born", "died", "species", "gender", "ageFactor", "ageExponent", "ageMixing" })
local lifestagesAndAges = {}
lifestagesAndAges[#lifestagesAndAges + 1] = { "child", 0 }
lifestagesAndAges[#lifestagesAndAges + 1] = { "juvenile", 12 }
lifestagesAndAges[#lifestagesAndAges + 1] = { "young", 20 }
lifestagesAndAges[#lifestagesAndAges + 1] = { "adult", 30 }
lifestagesAndAges[#lifestagesAndAges + 1] = { "old", 60 }
lifestagesAndAges[#lifestagesAndAges + 1] = { "ancient", 90 }

local function isAges(species)
	local factor, exponent = GetAgeFactorAndExponent(species)
	return factor ~= 0 and exponent ~= 0
end

local function getSpeciesRef(entity)
	local species = entity["species"]
	if IsEmpty(species) then
		return ""
	else
		return species
	end
end

local function getGender(entity)
	local gender = entity["gender"]
	if IsEmpty(gender) then
		return ""
	else
		return gender
	end
end

local function ageToYears(age, factor, exponent)
	return factor * age ^ exponent
end

local function yearsToAge(years, factor, exponent)
	return (years / factor) ^ (1 / exponent)
end

local function getMixedAgeFactorAndExponent(speciesMixing)
	if type(speciesMixing) ~= "table" or #speciesMixing ~= 2 then
		LogError("Called with " .. DebugPrint(speciesMixing))
		return 1, 1
	end
	local species1 = GetEntity(speciesMixing[1])
	local species2 = GetEntity(speciesMixing[2])
	if IsEmpty(species1) or IsEmpty(species2) then
		LogError("One of " .. DebugPrint(speciesMixing) .. " not found!")
		return 1, 1
	end
	local f1, e1 = GetAgeFactorAndExponent(species1)
	local f2, e2 = GetAgeFactorAndExponent(species2)
	return math.sqrt(f1 * f2), math.sqrt(e1 * e2)
end

function GetAgeFactorAndExponent(species)
	local speciesMixing = species["ageMixing"]
	if not IsEmpty(speciesMixing) then
		return getMixedAgeFactorAndExponent(speciesMixing)
	end
	local factor = GetNumberField(species, "ageFactor", 1)
	local exponent = GetNumberField(species, "ageExponent", 1)
	return factor, exponent
end

local function correspondingHumanAgeString(species, age)
	local factor, exponent = GetAgeFactorAndExponent(species)
	local out = {}
	if factor ~= 1 or exponent ~= 1 then
		local specificAge = yearsToAge(age, factor, exponent)
		local specificAgeString = RoundedNumString(specificAge, 0)
		Append(out, " (")
		Append(out, Tr("corresponding-human-age"))
		Append(out, " ")
		Append(out, specificAgeString)
		Append(out, " ")
		Append(out, Tr("years"))
		Append(out, ")")
	end
	return table.concat(out)
end

local function specificAgeString(entity, age)
	local speciesRef = getSpeciesRef(entity)
	if IsEmpty(speciesRef) then
		return ""
	end
	local species = GetEntity(speciesRef)
	if IsEmpty(species) then
		return ""
	end
	if isAges(species) then
		return correspondingHumanAgeString(species, age)
	else
		return " (" .. Tr("does-not-age") .. ")"
	end
end

local function ageString(entity, year)
	local out = {}
	if IsDead(entity) then
		Append(out, Tr("aged"))
		Append(out, " ")
	end
	local age = GetAgeInYears(entity, year)
	if IsEmpty(age) or age < 0 then
		return ""
	end
	Append(out, tostring(age))
	Append(out, " ")
	Append(out, Tr("years-old"))
	Append(out, specificAgeString(entity, age))
	return table.concat(out)
end

function SpeciesAndAgeString(entity, year)
	local parts = {}
	local speciesRef = getSpeciesRef(entity)
	if not IsEmpty(speciesRef) then
		Append(parts, TexCmd("nameref ", speciesRef))
	else
		LogError(GetShortname(entity) .. " has no species defined!")
	end
	local gender = getGender(entity)
	if not IsEmpty(gender) then
		Append(parts, gender)
	end
	local ageDescription = ageString(entity, year)
	if not IsEmpty(ageDescription) then
		Append(parts, ageDescription)
	end
	local out = {}
	for i, elem in pairs(parts) do
		Append(out, elem)
		if i < #parts then
			Append(out, ", ")
		else
			Append(out, ".")
		end
	end
	return table.concat(out)
end

local function addLifestageHistoryItems(entity)
	local label = GetMainLabel(entity)
	local birthyear = tonumber(entity["born"])
	local speciesRef = getSpeciesRef(entity)
	local species = GetEntity(speciesRef)
	if not IsEmpty(label) and not IsEmpty(birthyear) and not IsEmpty(species) then
		local deathyear = tonumber(entity["died"])
		local factor, exponent = GetAgeFactorAndExponent(species)
		for i = 2, #lifestagesAndAges do
			local lifestage = lifestagesAndAges[i][1]
			local humanAge = lifestagesAndAges[i][2]
			local realAge = ageToYears(humanAge, factor, exponent)
			realAge = Round(realAge)
			local year = birthyear + realAge
			if deathyear == nil or year <= deathyear then
				local event = {}
				Append(event, TexCmd("nameref", label))
				Append(event, " ")
				Append(event, Tr("is"))
				Append(event, " ")
				Append(event, Tr(lifestage))
				Append(event, ".")
				local item = {}
				item["year"] = year
				item["day"] = 0
				item["event"] = table.concat(event)
				item["concerns"] = { label }
				if entity["historyItems"] == nil then
					entity["historyItems"] = {}
				end
				entity["historyItems"][#entity["historyItems"] + 1] = item
			end
		end
	end
end

function AddLifestageHistoryItemsToNPC(entity)
	StartBenchmarking("AddLifestageHistoryItemsToNPC")
	if IsType("characters", entity) then
		addLifestageHistoryItems(entity)
	end
	StopBenchmarking("AddLifestageHistoryItemsToNPC")
end

local function lifestagesDescription(species)
	if IsEmpty(species) then
		LogError("Called with " .. DebugPrint(species))
		return ""
	end
	local out = {}
	local factor, exponent = GetAgeFactorAndExponent(species)
	for i, stageAndAge in pairs(lifestagesAndAges) do
		local stage = stageAndAge[1]
		local begins = stageAndAge[2]
		begins = ageToYears(begins, factor, exponent)
		local beginsString = RoundedNumString(begins, 0)
		Append(out, TexCmd("subparagraph", CapFirst(Tr(stage))))
		Append(out, beginsString)
		if i < #lifestagesAndAges then
			local ends = lifestagesAndAges[i + 1][2]
			ends = ageToYears(ends, factor, exponent)
			local endsString = RoundedNumString(ends, 0)
			Append(out, "-")
			Append(out, endsString)
		else
			Append(out, "+")
		end
		Append(out, " ")
		Append(out, Tr("years"))
	end
	return table.concat(out)
end

function AddLifeStagesToSpecies(entity)
	StartBenchmarking("AddLifeStagesToSpecies")
	if IsType("species", entity) then
		if isAges(entity) then
			local lifestages = lifestagesDescription(entity)
			if not IsEmpty(lifestages) then
				SetDescriptor(entity, Tr("lifestages"), lifestages)
			end
		end
	end
	StopBenchmarking("AddLifeStagesToSpecies")
end
