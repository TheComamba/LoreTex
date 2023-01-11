TexApi.setAgeExponent = function(exponent)
    if tonumber(exponent) == nil then
        LogError("Age exponent must be a number. Function called with:" .. DebugPrint(exponent))
        return
    end
    if CurrentEntity == nil then
        LogError("Trying to set age exponent for no entity!")
        return
    end
    SetProtectedField(CurrentEntity, "ageExponent", exponent)
end

TexApi.setAgeFactor = function(factor)
    if tonumber(factor) == nil then
        LogError("Age factor must be a number. Function called with:" .. DebugPrint(factor))
        return
    end
    if CurrentEntity == nil then
        LogError("Trying to set age factor for no entity!")
        return
    end
    SetProtectedField(CurrentEntity, "ageFactor", factor)
end

TexApi.setAgeModifierMixing = function(species1, species2)
    if species1 == nil or species2 == nil or type(species1) ~= "string" or type(species2) ~= "string" then
        LogError("setAgeModifierMixing called with:" .. DebugPrint { species1, species2 })
        return
    end
    if CurrentEntity == nil then
        LogError("Trying to set age modifier mixing for no entity!")
        return
    end
    SetProtectedField(CurrentEntity, "ageMixing", { species1, species2 })
end

TexApi.setHeight = function(height)
    SetProtectedField(CurrentEntity, "height", height)
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

local function isLabelInTopEntities(label, entity)
    while entity ~= nil do
        local thisLabel = GetProtectedStringField(entity, "label")
        if label == thisLabel then
            return true
        end
        entity = GetProtectedNullableField(entity, "partOf")
    end
    return false
end

function MakePartOf(arg)
    if not IsArgOk("MakePartOf", arg, { "subEntity", "mainEntity" }) then
        return
    end

    local label = GetProtectedStringField(arg.subEntity, "label")
    if isLabelInTopEntities(label, arg.mainEntity) then
        LogError("Trying to make entity with label \"" .. label .. "\" part of a hierarchy that already contains it.")
        return
    end
    SetProtectedField(arg.subEntity, "partOf", arg.mainEntity)
end
