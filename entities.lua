Entities = {}
IsShowSecrets = false
ProtectedDescriptors = { "name", "shortname", "type", "isSecret", "isShown", "labels" }

function DebugPrint(entity)
    if entity == nil then
        return "nil"
    elseif type(entity) == "string" then
        return " \"" .. entity .. "\" "
    elseif type(entity) ~= "table" then
        return tostring(entity)
    end
    local out = {}
    local keys = {}
    for key, elem in pairs(entity) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    for i, key in pairs(keys) do
        if i == 1 then
            Append(out, [[\{]])
        else
            Append(out, ", ")
        end
        Append(out, key)
        Append(out, " = ")
        Append(out, DebugPrint(entity[key]))
        if i == #keys then
            Append(out, [[\}]])
        end
    end
    return table.concat(out)
end

function CurrentEntity()
    return Entities[#Entities]
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

function GetMainLabel(entity)
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
    if list == nil then
        list = Entities
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
        list = Entities
    end
    for key, entity in pairs(list) do
        if entity["type"] == type then
            out[#out + 1] = entity
        end
    end
    return out
end

function GetEntity(label)
    if IsEmpty(label) then
        LogError("Called with empty label!")
        return {}
    elseif type(label) ~= "string" then
        LogError("Called with non-string type!")
        return {}
    end
    for key, entity in pairs(Entities) do
        if IsIn(label, GetLabels(entity)) then
            return entity
        end
    end
    if not IsIn(label, UnfoundRefs) then
        LogError("Entity with label \"" .. label .. "\" not found.")
        AddRef(label, UnfoundRefs)
    end
    return {}
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
    local out = {}
    for i, key in pairs(allTypes) do
        out[key] = allTypeNames[i]
    end
    return out
end

function TypeToName(type)
    return typeToNameMap()[type]
end

local function getTargetCondition(keyword)
    if keyword == "location" then
        return IsPlace
    elseif keyword == "association" then
        return IsAssociation
    end
end

local function addSingleEntity(srcEntity, targetEntity, entityType, role)
    local name = TypeToName(entityType)
    if targetEntity[name] == nil then
        targetEntity[name] = {}
    end
    local content = {}
    if IsSecret(srcEntity) then
        Append(content, "(Geheim) ")
    end
    local srcLabel = GetMainLabel(srcEntity)
    Append(content, TexCmd("myref ", srcLabel))
    if IsDead(srcEntity) then
        Append(content, " " .. TexCmd("textdied"))
    end
    local location = srcEntity["location"]
    local targetLocation = targetEntity["location"]
    local locationRef = ""
    if not IsPlace(targetEntity) and not IsEmpty(location) and location ~= targetLocation then
        locationRef = "in " .. TexCmd("myref ", location)
    end
    if not IsEmpty(role) or not IsEmpty(locationRef) then
        Append(content, " (")
        if not IsEmpty(role) then
            Append(content, role)
        end
        if not IsEmpty(role) and not IsEmpty(locationRef) then
            Append(content, ", ")
        end
        if not IsEmpty(locationRef) then
            Append(content, locationRef)
        end
        Append(content, ")")
    end
    targetEntity[name][#targetEntity[name] + 1] = table.concat(content)
end

local function addEntitiesTo(entityType, keyword)
    local entityMap = GetEntitiesOfType(entityType)
    entityMap = GetEntitiesIf(IsShown, entityMap)
    for label, srcEntity in pairs(entityMap) do
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
                local targetCondition = getTargetCondition(keyword)
                local targetEntity = GetEntity(targetLabel)
                if targetEntity == nil then
                    local err = { "Entity \"" }
                    Append(err, targetLabel)
                    Append(err, "\" not found, although it is listed as ")
                    Append(err, keyword)
                    Append(err, " of ")
                    Append(err, label)
                    Append(err, ".")
                    LogError(err)
                elseif not targetCondition(targetEntity) then
                    LogError("Entity \"" .. targetLabel .. "\" is not a " .. keyword .. ".")
                else
                    addSingleEntity(srcEntity, targetEntity, entityType, role)
                end
            end
        end
    end
end

local function addAllEntitiesTo()
    for type, name in pairs(typeToNameMap()) do
        for key2, keyword in pairs({ "location", "association" }) do
            addEntitiesTo(type, keyword)
        end
    end
end

local function addPrimaryPlaceEntitiesToRefs()
    local places = GetEntitiesIf(IsPlace)
    local primaryPlaces = GetEntitiesIf(IsPrimary, places)
    for placeLabel, place in pairs(primaryPlaces) do
        for type, typeName in pairs(typeToNameMap()) do
            local entitiesHere = place[typeName]
            AddRef(ScanForCmd(entitiesHere, "myref"), PrimaryRefs)
        end
    end
end

local function checkAllRefs()
    for key, label in pairs(PrimaryRefs) do
        GetEntity(label)
    end
    for key, label in pairs(SecondaryRefs) do
        GetEntity(label)
    end
end

function ScanEntitiesForLabels()
    for key, entity in pairs(Entities) do
        local labels = GetLabels(entity)
        local additionalLabels = ScanForCmd(entity, "label")
        Append(labels, additionalLabels)
    end
end

function AddAutomatedDescriptors()
    AddHistoryDescriptors()
    addAllEntitiesTo()
    AddSpeciesAndAgeStringToNPCs()
    AddAssociationDescriptors()
end

function ComplementRefs()
    addPrimaryPlaceEntitiesToRefs()
    AddPrimaryPlaceParentsToRefs()
    local primaryEntities = GetEntitiesIf(IsPrimary, Entities)
    ScanContentForSecondaryRefs(primaryEntities)
    ReplaceMyrefWithNameref(primaryEntities)
    checkAllRefs()
end

dofile(RelativePath .. "entities-geography.lua")
dofile(RelativePath .. "entities-characters.lua")
dofile(RelativePath .. "entities-associations.lua")
dofile(RelativePath .. "entities-landmarks.lua")
dofile(RelativePath .. "entities-languages.lua")
dofile(RelativePath .. "entities-items.lua")
dofile(RelativePath .. "entities-history.lua")
dofile(RelativePath .. "entities-print.lua")
dofile(RelativePath .. "entities-tex-api.lua")
