PCs = {}

StateResetters[#StateResetters + 1] = function()
    PCs = {}
end

function AddSpeciesAndAgeString(entity)
    local speciesAndAgeStr = SpeciesAndAgeString(entity)
    if speciesAndAgeStr ~= "" then
        SetDescriptor { entity = entity,
            descriptor = Tr("appearance"),
            subdescriptor = CapFirst(Tr("species_and_age")) .. ":",
            description = speciesAndAgeStr }
    end
end

function IsBorn(entity)
    return IsHasHappened(entity, "born", true)
end

function IsDead(entity)
    return IsHasHappened(entity, "died", false)
end

local function getYear(entity, key)
    local value = GetProtectedNullableField(entity, key)
    if value == nil then
        return nil
    end
    local year = tonumber(value)
    if year == nil then
        LogError { "Could not convert ", DebugPrint(value), " to year in entity: ", DebugPrint(entity) }
        return nil
    else
        return year
    end
end

function GetAgeInYears(entity, year)
    if year == nil or type(year) ~= "number" then
        LogError { "Called with ", DebugPrint(year) }
        return nil
    end
    local born = getYear(entity, "born")
    local died = getYear(entity, "died")
    if born == nil then
        return nil
    elseif died == nil or died > year then
        return year - born
    else
        return died - born
    end
end
