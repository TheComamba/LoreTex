Append(ProtectedDescriptors, {"born", "died", "species", "gender"})
SpeciesTypes = { "species"}
SpeciesTypeNames = { "Spezies" }

function IsSpecies(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], SpeciesTypes)
end

function SpeciesAndAgeString(npc, year)
	local str = ""

	local speciesName = npc["species"]
	local gender = npc["gender"]
	if speciesName ~= nil and Species[speciesName] ~= nil then
		if gender ~= nil then
			local gen = Species[speciesName]["genitive"]
			if gender == "male" then
				str = str .. gen .. "-Mann"
			elseif gender == "female" then
				str = str .. gen .. "-Frau"
			else
				str = str .. gen .. "-Person"
			end
		else
			str = str .. Species[speciesName]["nominative"]
		end
	end

	local born = npc["born"]
	if born ~= nil then
		born = tonumber(born)
		if str ~= "" then
			str = str .. ", "
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
				str = str .. "wurde "
			end
		end
		str = str .. age .. " Jahre "
		if speciesName ~= nil and Species[speciesName] ~= nil and Species[speciesName]["ageExponent"] ~= 1 then
			str = str .. "(" .. HumanToSpecies(age, speciesName) .. " "
			str = str .. Species[speciesName]["genitive"] .. "jahre) "
		end
		str = str .. "alt."
	end

	return str
end

local function getSpecies(entity)
    local species = entity["species"]
    if species == nil then
        species = ""
    end
    return species
end

function AddSpeciesToPrimaryRefs()
    local primaryEntities = GetEntitiesIf(IsPrimary)
    for key, entity in pairs(primaryEntities) do
        local speciesRef = getSpecies(entity)
        if not IsEmpty(speciesRef) then
            AddRef(speciesRef, PrimaryRefs)
        end
    end
end