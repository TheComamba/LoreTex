Entities = {}
CurrentLabel = ""
IsShowSecrets = false
ProtectedDescriptors = { "name", "shortname", "type", "parent", "location", "born", "died", "species", "gender",
    "association", "isSecret", "isShown", "label" }

function GetEntitiesIf(condition, map)
    local out = {}
    if map == nil then
        map = Entities
    end
    for key, entity in pairs(map) do
        if condition(entity) then
            out[key] = entity
        end
    end
    return out
end

function GetEntitiesOfType(type, map)
    local out = {}
    if map == nil then
        map = Entities
    end
    for key, entity in pairs(map) do
        if entity["type"] == type then
            out[key] = entity
        end
    end
    return out
end

function GetPrimaryRefEntities(map)
    local out = {}
    for label, elem in pairs(map) do
        if IsIn(label, PrimaryRefs) then
            out[label] = elem
        end
    end
    return out
end

function ToEntity(input)
    if input == nil then
        LogError("called with nil input.")
        return nil
    elseif type(input) == "table" then
        return input
    elseif type(input) == "string" then
        local entity = Entities[input]
        if entity == nil then
            if not IsIn(input, UnfoundRefs) then
                LogError("Entity with label \"" .. input .. "\" not found.")
                AddRef(input, UnfoundRefs)
            end
            return nil
        else
            return entity
        end
    else
        LogError("Tried to convert input of type " .. type(input) .. " to entity.")
        return nil
    end
end

function ToLabel(input)
    if input == nil then
        return nil
    elseif type(input) == "string" then
        return input
    elseif type(input) == "table" then
        return input["label"]
    else
        return nil
    end
end

function IsSecret(entity)
    entity = ToEntity(entity)
    if entity == nil then
        return false
    end
    local isSecret = entity["isSecret"]
    if isSecret == nil then
        return false
    end
    if type(isSecret) ~= "boolean" then
        LogError("isSecret property of " .. entity["label"] .. " should be boolean, but is " .. type(isSecret) .. ".")
        return false
    end
    return isSecret
end

function IsShown(entity)
    entity = ToEntity(entity)
    if IsEmpty(entity) then
        return false
    elseif IsShowSecrets then
        return true
    elseif not IsSecret(entity) then
        return true
    elseif entity["isShown"] ~= nil then
        return entity["isShown"]
    else
        local label = ToLabel(entity)
        if label == nil then
            return false
        end
        if IsIn(label, PrimaryRefs) then
            entity["isShown"] = true
            return true
        else
            return false
        end
    end
end

function CompareLabelsByName(label1, label2)
    local name1 = GetShortname(label1)
    local name2 = GetShortname(label2)
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

local function addSingleEntity(label, targetLabel, entityType, role)
    local name = TypeToName(entityType)
    if Entities[targetLabel][name] == nil then
        Entities[targetLabel][name] = {}
    end
    local content = {}
    if IsSecret(label) then
        Append(content, "(Geheim) ")
    end
    Append(content, TexCmd("myref ", label))
    if IsDead(label) then
        Append(content, " " .. TexCmd("textdied"))
    end
    local location = Entities[label]["location"]
    local targetLocation = Entities[targetLabel]["location"]
    local locationRef = ""
    if not IsEmpty(location) and location ~= targetLocation then
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
    Entities[targetLabel][name][#Entities[targetLabel][name] + 1] = table.concat(content)
end

local function addEntitiesTo(entityType, keyword)
    local entityMap = GetEntitiesOfType(entityType)
    entityMap = GetEntitiesIf(IsShown, entityMap)
    for label, entity in pairs(entityMap) do
        local targets = entity[keyword]
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
                if Entities[targetLabel] == nil then
                    local err = { "Entity \"" }
                    Append(err, targetLabel)
                    Append(err, "\" not found, although it is listed as ")
                    Append(err, keyword)
                    Append(err, " of ")
                    Append(err, label)
                    Append(err, ".")
                    LogError(err)
                elseif not targetCondition(Entities[targetLabel]) then
                    LogError("Entity \"" .. targetLabel .. "\" is not a " .. keyword .. ".")
                else
                    addSingleEntity(label, targetLabel, entityType, role)
                end
            end
        end
    end
end

local function addAllEntitiesTo()
    for type, name in pairs(typeToNameMap()) do
        for key2, keyword in pairs({ "association" }) do
            addEntitiesTo(type, keyword)
        end
    end
end

local function addPrimaryPlaceEntitiesToRefs()
    local places = GetEntitiesIf(IsPlace)
    local primaryPlaces = GetPrimaryRefEntities(places)
    for placeLabel, place in pairs(primaryPlaces) do
        for type, typeName in pairs(typeToNameMap()) do
            local entitiesHere = place[typeName]
            AddRef(ScanForRefs(entitiesHere), PrimaryRefs)
        end
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
    local primaryEntities = GetPrimaryRefEntities(Entities)
    ScanContentForSecondaryRefs(primaryEntities)
    ReplaceMyrefWithNameref(primaryEntities)
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
