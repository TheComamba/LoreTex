function IsProtectedDescriptor(descriptor)
    return string ~= "" and string.sub(descriptor, 1, 1) == "_"
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
        return ""
    else
        return out
    end
end

function GetProtectedTableFieldReference(entity, key)
    local out = getProtectedField(entity, key)
    if out == nil then
        return {}
    elseif type(out) ~= "table" then
        LogError("Expected table, got " .. type(out) .. " for key \"" .. key .. "\"!")
        return {}
    else
        return out
    end
end

function GetProtectedTableField(entity, key)
    return DeepCopy(GetProtectedTableFieldReference(entity, key))
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
    local locationLabel = GetProtectedStringField(location, "label")
    addParent { entity = entity, parentLabel = locationLabel, relationship = GetProtectedDescriptor("location") }
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
