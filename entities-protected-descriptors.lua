local protectedDescriptors = {}

local function addProtectedDescriptor(descriptor)
    protectedDescriptors[descriptor] = "_" .. descriptor .. "_"
end

addProtectedDescriptor("ageExponent")
addProtectedDescriptor("ageFactor")
addProtectedDescriptor("ageMixing")
addProtectedDescriptor("birthof")
addProtectedDescriptor("born")
addProtectedDescriptor("children")
addProtectedDescriptor("concerns")
addProtectedDescriptor("counter")
addProtectedDescriptor("day")
addProtectedDescriptor("deathof")
addProtectedDescriptor("died")
addProtectedDescriptor("event")
addProtectedDescriptor("historyItems")
addProtectedDescriptor("isConcernsOthers")
addProtectedDescriptor("isSecret")
addProtectedDescriptor("labels")
addProtectedDescriptor("location")
addProtectedDescriptor("monthsAndFirstDays")
addProtectedDescriptor("name")
addProtectedDescriptor("originator")
addProtectedDescriptor("parents")
addProtectedDescriptor("species")
addProtectedDescriptor("shortname")
addProtectedDescriptor("type")
addProtectedDescriptor("year")
addProtectedDescriptor("yearAbbreviation")
addProtectedDescriptor("yearFormat")
addProtectedDescriptor("yearOffset")

function IsProtectedDescriptor(descriptor)
    for key, protectedDescriptor in pairs(protectedDescriptors) do
        if protectedDescriptor == descriptor then
            return true
        end
    end
    return false
end

function GetProtectedField(entity, key)
    local descriptor = GetProtectedDescriptor(key)
    return entity[descriptor]
end

function SetProtectedField(entity, key, value)
    local descriptor = GetProtectedDescriptor(key)
    entity[descriptor] = value
end

function AddToProtectedField(entity, key, value)
    local descriptor = GetProtectedDescriptor(key)
    if entity[descriptor] == nil then
        entity[descriptor] = {}
    end
    entity[descriptor][#entity[descriptor] + 1] = value
end

function GetProtectedDescriptor(key)
    local descriptor = protectedDescriptors[key]
    if descriptor == nil then
        LogError("Key \"" .. key .. "\" does not name a protected descriptor.")
        return ""
    end
    return descriptor
end

function SetAgeExponent(entity, exponent)
    SetProtectedField(entity, "ageExponent", exponent)
end

function SetAgeFactor(entity, factor)
    SetProtectedField(entity, "ageFactor", factor)
end

function SetAgeModifierMixing(entity, species1, species2)
    SetProtectedField(entity, "ageMixing", { species1, species2 })
end

function SetLocation(entity, location)
    SetProtectedField(entity, "location", location)
    AddParent(entity, location, GetProtectedDescriptor("location"))
end

function AddParent(entity, parentLabel, relationship)
    if entity ~= nil then
        AddToProtectedField(entity, "parents", { parentLabel, relationship })
    end
    local parent = GetMutableEntityFromAll(parentLabel)
    AddToProtectedField(parent, "children", GetMainLabel(entity))
end

function SetSecret(entity)
    SetProtectedField(entity, "isSecret", true)
end

function SetSpecies(entity, species)
    SetProtectedField(entity, "species", species)
end
