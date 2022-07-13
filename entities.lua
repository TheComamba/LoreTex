Entities = {}
CurrentLabel = ""
ProtectedDescriptors = { "name", "shortname", "type", "parent", "location", "born", "died", "species", "gender",
    "association" }

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

local function addEntitiesTo(type, keyword)
    local entityMap = GetEntitiesOfType(type)
    for label, entity in pairs(entityMap) do
        local targetLabel = entity[keyword]
        local role = entity[keyword .. "-role"]
        if targetLabel ~= nil then
            local targetCondition = getTargetCondition(keyword)
            if Entities[targetLabel] == nil then
                LogError("Entity \"" .. targetLabel .. "\" not found.")
            elseif not targetCondition(Entities[targetLabel]) then
                LogError("Entity \"" .. targetLabel .. "\" is not a " .. keyword .. ".")
            else
                local name = TypeToName(type)
                if Entities[targetLabel][name] == nil then
                    Entities[targetLabel][name] = {}
                end
                local content = TexCmd("myref ", label)
                if not IsEmpty(role) then
                    content = content .. " (" .. role .. ")"
                end
                Entities[targetLabel][name][#Entities[targetLabel][name] + 1] = content
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
