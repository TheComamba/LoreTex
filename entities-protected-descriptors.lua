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
addProtectedDescriptor("content")
addProtectedDescriptor("counter")
addProtectedDescriptor("day")
addProtectedDescriptor("deathof")
addProtectedDescriptor("died")
addProtectedDescriptor("historyItems")
addProtectedDescriptor("isConcernsOthers")
addProtectedDescriptor("isSecret")
addProtectedDescriptor("labels")
addProtectedDescriptor("location")
addProtectedDescriptor("monthsAndFirstDays")
addProtectedDescriptor("name")
addProtectedDescriptor("originator")
addProtectedDescriptor("parents")
addProtectedDescriptor("partOf")
addProtectedDescriptor("shortname")
addProtectedDescriptor("species")
addProtectedDescriptor("subEntities")
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

local function getProtectedField(entity, key)
    local descriptor = GetProtectedDescriptor(key)
    return entity[descriptor]
end

function GetProtectedNullableField(entity, key)
    return getProtectedField(entity, key)
end

function GetProtectedStringField(entity, key)
    local out = getProtectedField(entity, key)
    if out == nil then
        return ""
    elseif type(out) ~= "string" then
        LogError("Expected string, got " .. type(out) .. " for key \"" .. key .. "\"!")
    else
        return out
    end
end

function GetProtectedTableField(entity, key)
    local out = getProtectedField(entity, key)
    if out == nil then
        return {}
    elseif type(out) ~= "table" then
        LogError("Expected table, got " .. type(out) .. " for key \"" .. key .. "\"!")
    else
        return out
    end
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

TexApi.setAgeExponent = function(exponent)
    SetProtectedField(CurrentEntity, "ageExponent", exponent)
end

TexApi.setAgeFactor = function(factor)
    SetProtectedField(CurrentEntity, "ageFactor", factor)
end

TexApi.setAgeModifierMixing = function(species1, species2)
    SetProtectedField(CurrentEntity, "ageMixing", { species1, species2 })
end

local function addParent(arg)
    if not IsArgOk("addParent", arg, { "entity", "parentLabel" }, { "relationship" }) then
        return
    end
    local parent = GetMutableEntityFromAll(arg.parentLabel)
    AddToProtectedField(arg.entity, "parents", { parent, arg.relationship })
    AddToProtectedField(parent, "children", arg.entity)
end

TexApi.addParent = function(arg)
    arg.entity = CurrentEntity
    addParent(arg)
end

function SetLocation(entity, location)
    SetProtectedField(entity, "location", location)
    addParent { entity = entity, parentLabel = GetMainLabel(location), relationship = GetProtectedDescriptor("location") }
end

TexApi.setLocation = function(locationLabel)
    local location = GetMutableEntityFromAll(locationLabel)
    SetLocation(CurrentEntity, location)
end

TexApi.setSecret = function()
    SetProtectedField(CurrentEntity, "isSecret", true)
end

TexApi.setSpecies = function(speciesLabel)
    local species = GetMutableEntityFromAll(speciesLabel)
    SetProtectedField(CurrentEntity, "species", species)
end

function MakePartOf(arg)
    if not IsArgOk("MakePartOf", arg, { "subEntity", "mainEntity" }) then
        return
    end

    SetProtectedField(arg.subEntity, "partOf", arg.mainEntity)
    AddToProtectedField(arg.mainEntity, "subEntities", arg.subEntity)
end
