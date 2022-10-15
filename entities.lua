AllEntities = {}
IsShowSecrets = false
ProtectedDescriptors = { "name", "shortname", "type", "isSecret", "isShown", "labels" }
OtherEntityTypes = { "other" }
OtherEntityTypeNames = { "Andere" }

function IsOtherEntity(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], OtherEntityTypes)
end

function CurrentEntity()
    return AllEntities[#AllEntities]
end

function GetLabels(entity)
    local labels = entity["labels"]
    if labels == nil then
        LogError("This entity has no labels field: " .. DebugPrint(entity))
        return {}
    elseif type(labels) ~= "table" then
        LogError("This entities' labels field is not a list: " .. DebugPrint(entity))
        return {}
    else
        return labels
    end
end

function GetNumberField(entity, key, default)
    local out = entity[key]
    if out == nil then
        out = default
    elseif tonumber(out) == nil then
        LogError("Could not convert to number: " .. DebugPrint(out))
        out = default
    else
        out = tonumber(out)
    end
    return out
end

function GetMainLabel(entity)
    if type(entity) ~= "table" then
        LogError("Called with " .. DebugPrint(entity))
        return "CALLED WITH WRONG TYPE"
    end
    local labels = GetLabels(entity)
    if IsEmpty(labels) then
        return "MAIN LABEL NOT FOUND"
    else
        return labels[1]
    end
end

function IsPrimary(entity)
    local labels = GetLabels(entity)
    return IsAnyElemIn(labels, PrimaryRefs)
end

function IsSecondary(entity)
    local labels = GetLabels(entity)
    return IsAnyElemIn(labels, SecondaryRefs) and not IsPrimary(entity)
end

function GetEntitiesIf(condition, list)
    local out = {}
    if list == nil or type(list) ~= "table" then
        LogError("Called with " .. DebugPrint(list))
        return out
    end
    for key, entity in pairs(list) do
        if condition(entity) then
            out[#out + 1] = entity
        end
    end
    return out
end

function GetEntitiesOfType(type, list)
    local out = {}
    if list == nil then
        list = AllEntities
    end
    for key, entity in pairs(list) do
        if entity["type"] == type then
            out[#out + 1] = entity
        end
    end
    return out
end

local function getEntityRaw(label, entityList)
    if IsEmpty(label) then
        LogError("Called with empty label!")
        return {}
    elseif type(label) ~= "string" then
        LogError("Called with non-string type!")
        return {}
    elseif IsEmpty(entityList) or type(entityList) ~= "table" then
        LogError("getEntityRaw called with " .. DebugPrint(entityList))
        return {}
    end
    for key, entity in pairs(entityList) do
        if IsIn(label, GetLabels(entity)) then
            return entity
        end
    end
    return {}
end

function GetEntity(label)
    local entity = getEntityRaw(label, AllEntities)
    if IsEmpty(entity) and not IsIn(label, UnfoundRefs) then
        LogError("Entity with label \"" .. label .. "\" not found.")
        AddRef(label, UnfoundRefs)
    end
    return ReadonlyTable(entity)
end

function GetMutableEntity(label, entityList)
    if entityList == AllEntities then
        LogError("Trying to get mutable reference to member of AllEntities.")
        return {}
    end
    return getEntityRaw(label, entityList)
end

function IsSecret(entity)
    if entity == nil then
        return false
    end
    local isSecret = entity["isSecret"]
    if isSecret == nil then
        return false
    end
    if type(isSecret) ~= "boolean" then
        LogError("isSecret property of " .. DebugPrint(entity) .. " should be boolean, but is " .. type(isSecret) .. ".")
        return false
    end
    return isSecret
end

function IsShown(entity)
    if IsEmpty(entity) then
        return false
    elseif not IsBorn(entity) then
        return false
    elseif IsShowSecrets then
        return true
    elseif not IsSecret(entity) then
        return true
    elseif entity["isShown"] ~= nil then
        return entity["isShown"]
    else
        local labels = GetLabels(entity)
        for key, label in pairs(labels) do
            if IsIn(label, PrimaryRefs) then
                entity["isShown"] = true
                return true
            end
        end
        return false
    end
end

function CompareByName(entity1, entity2)
    local name1 = GetShortname(entity1)
    local name2 = GetShortname(entity2)
    return name1 < name2
end

local function typeToNameMap()
    local allTypes = {}
    local allTypeNames = {}
    Append(allTypes, AssociationTypes)
    Append(allTypeNames, AssociationTypeNames)
    Append(allTypes, CharacterTypes)
    Append(allTypeNames, CharacterTypeNames)
    Append(allTypes, PlaceTypes)
    Append(allTypeNames, PlaceTypeNames)
    Append(allTypes, ItemTypes)
    Append(allTypeNames, ItemTypeNames)
    Append(allTypes, LanguageTypes)
    Append(allTypeNames, LanguageTypeNames)
    Append(allTypes, LandmarkTypes)
    Append(allTypeNames, LandmarkTypeNames)
    Append(allTypes, SpeciesTypes)
    Append(allTypeNames, SpeciesTypeNames)
    Append(allTypes, SpellTypes)
    Append(allTypeNames, SpellTypeNames)
    Append(allTypes, ClassTypes)
    Append(allTypeNames, ClassTypeNames)
    Append(allTypes, OtherEntityTypes)
    Append(allTypeNames, OtherEntityTypeNames)
    local out = {}
    for i, key in pairs(allTypes) do
        out[key] = allTypeNames[i]
    end
    return out
end

function TypeToName(type)
    return typeToNameMap()[type]
end

local function entityQualifiersString(srcEntity, targetEntity, role)
    local content = {}
    if IsSecret(srcEntity) then
        Append(content, "Geheim")
    end
    if not IsEmpty(role) then
        Append(content, role)
    end
    local birthyearstr = srcEntity["born"]
    local birthyear = tonumber(birthyearstr)
    if not IsEmpty(birthyear) and birthyear <= CurrentYearVin then
        birthyear = ConvertYearFromVin(birthyear, YearFmt)
        Append(content, TexCmd("textborn") .. birthyear)
    end
    local deathyearstr = srcEntity["died"]
    local deathyear = tonumber(deathyearstr)
    if not IsEmpty(deathyear) and deathyear <= CurrentYearVin then
        deathyear = ConvertYearFromVin(deathyear, YearFmt)
        Append(content, TexCmd("textdied") .. deathyear)
    end
    local location = srcEntity["location"]
    local targetLocation = targetEntity["location"]
    if not IsPlace(targetEntity) and not IsEmpty(location) and location ~= targetLocation then
        Append(content, "in " .. TexCmd("nameref", location))
    end
    if not IsEmpty(content) then
        return "(" .. table.concat(content, ", ") .. ")"
    else
        return ""
    end
end

local function addSingleEntity(srcEntity, targetEntity, entityType, role)
    local name = TypeToName(entityType)
    if targetEntity[name] == nil then
        targetEntity[name] = {}
    end
    local content = {}
    local srcLabel = GetMainLabel(srcEntity)
    Append(content, TexCmd("nameref", srcLabel))
    Append(content, " ")
    Append(content, entityQualifiersString(srcEntity, targetEntity, role))
    UniqueAppend(targetEntity[name], table.concat(content))
end

local function addEntitiesTo(entityType, keyword, entities)
    local srcEntities = GetEntitiesOfType(entityType)
    srcEntities = GetEntitiesIf(IsShown, srcEntities)
    for label, srcEntity in pairs(srcEntities) do
        local targets = srcEntity[keyword]
        if targets ~= nil then
            if type(targets) ~= "table" then
                targets = { targets }
            end
            for key, target in pairs(targets) do
                local targetLabel = ""
                local role = ""
                if type(target) == "string" then
                    targetLabel = target
                elseif type(target) == "table" then
                    targetLabel = target[1]
                    role = target[2]
                end
                local targetEntity = GetMutableEntity(targetLabel, entities)
                if targetEntity ~= nil then
                    addSingleEntity(srcEntity, targetEntity, entityType, role)
                end
            end
        end
    end
end

local function addAllEntitiesTo(entities)
    for type, name in pairs(typeToNameMap()) do
        for key2, keyword in pairs({ "location", "association" }) do
            addEntitiesTo(type, keyword, entities)
        end
    end
end

function AddAutomatedDescriptors(entities)
    addAllEntitiesTo(entities)
    ProcessHistory(entities)
    AddAssociationDescriptors(entities)
    for key, entity in pairs(entities) do
        AddSpeciesAndAgeStringToNPC(entity)
        AddLifeStagesToSpecies(entity)
    end
end

function IsType(types, entity)
    if IsEmpty(entity) then
        LogError("Called with empty entity!")
        return false
    end
    return IsIn(entity["type"], types)
end

local function isEntityIn(entity, entities)
    if IsEmpty(entities) then
        return false
    end
    local label = GetMainLabel(entity)
    local testEntity = GetMutableEntity(label, entities)
    return not IsEmpty(testEntity)
end

local function addProcessedEntity(entities, entity)
    if not isEntityIn(entity, entities) then
        local newEntity = DeepCopy(entity)
        MarkDead(entity)
        MarkSecret(entity)
        entities[#entities + 1] = newEntity
    end
end

function ProcessEntities(entitiesIn)
    local entitiesOut = {}
    for key, entity in pairs(GetEntitiesIf(IsPrimary, entitiesIn)) do
        addProcessedEntity(entitiesOut, entity)
    end

    --TODO: Funktionen für nur eine entity
    AddAutomatedDescriptors(entitiesOut)
    ScanContentForSecondaryRefs(entitiesOut)
    return entitiesOut
end

dofile(RelativePath .. "/entities-geography.lua")
dofile(RelativePath .. "/entities-landmarks.lua")
dofile(RelativePath .. "/entities-characters.lua")
dofile(RelativePath .. "/entities-associations.lua")
dofile(RelativePath .. "/entities-species.lua")
dofile(RelativePath .. "/entities-languages.lua")
dofile(RelativePath .. "/entities-classes.lua")
dofile(RelativePath .. "/entities-spells.lua")
dofile(RelativePath .. "/entities-items.lua")
dofile(RelativePath .. "/entities-history.lua")
dofile(RelativePath .. "/entities-print.lua")
dofile(RelativePath .. "/entities-tex-api.lua")
