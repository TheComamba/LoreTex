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
	local speciesMixing = GetProtectedNullableField(species, "ageMixing")
	if not IsEmpty(speciesMixing) then
		return getMixedAgeFactorAndExponent(speciesMixing)
	end
	local factor = GetProtectedNullableField(species, "ageFactor")
	if factor == nil then
		factor = 1
	end
	local exponent = GetProtectedNullableField(species, "ageExponent")
	if exponent == nil then
		exponent = 1
	end
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
	local species = GetProtectedNullableField(entity, "species")
	if species == nil then
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
	if age == nil or age < 0 then
		return ""
	end
	Append(out, tostring(age))
	Append(out, " ")
	Append(out, Tr("years-old"))
	Append(out, specificAgeString(entity, age))
	return table.concat(out)
end

function SpeciesAndAgeString(entity)
	local parts = {}
	local species = GetProtectedNullableField(entity, "species")
	if species ~= nil then
		Append(parts, TexCmd("nameref ", GetProtectedStringField(species, "label")))
	end
	if IsCurrentYearSet then
		local ageDescription = ageString(entity, GetCurrentYear())
		if ageDescription ~= "" then
			Append(parts, ageDescription)
		end
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
	local label = GetProtectedStringField(entity, "label")
	if label == "" then
		return
	end
	local birthyear = GetProtectedInheritableField(entity, "born")
	if birthyear == nil then
		return
	end
	local species = GetProtectedNullableField(entity, "species")
	if species == nil then
		return
	end
	local deathyear = GetProtectedInheritableField(entity, "died")
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
			local item = NewHistoryItem()
			SetYear(item, year)
			SetProtectedField(item, "content", table.concat(event))
			AddToProtectedField(item, "mentions", entity)
			AddToProtectedField(entity, "historyItems", item)
		end
	end
end

function AddLifestageHistoryItemsToNPC(entity)
	if IsType("characters", entity) then
		addLifestageHistoryItems(entity)
	end
end

local function lifestagesDescription(species)
	local out = {}
	local factor, exponent = GetAgeFactorAndExponent(species)
	for i, stageAndAge in pairs(lifestagesAndAges) do
		local stage = stageAndAge[1]
		local begins = stageAndAge[2]
		begins = ageToYears(begins, factor, exponent)
		local beginsString = RoundedNumString(begins, 0)
		local caption = TexCmd("comment", i) .. CapFirst(Tr(stage))
		Append(out, TexCmd("subparagraph", caption))
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
	if IsType("species", entity) then
		if isAges(entity) then
			local lifestages = lifestagesDescription(entity)
			if lifestages ~= "" then
				SetDescriptor { entity = entity, descriptor = Tr("lifestages"), description = lifestages }
			end
		end
	end
end
