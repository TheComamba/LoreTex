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

function TypeToName(type)
    local typesAndNames = {}
    typesAndNames[#typesAndNames + 1] = { CharacterTypes, CharacterTypeNames }
    typesAndNames[#typesAndNames + 1] = { ItemTypes, ItemTypeNames }
    typesAndNames[#typesAndNames + 1] = { LanguageTypes, LanguageTypeNames }
    typesAndNames[#typesAndNames + 1] = { AssociationTypes, AssociationTypeNames }
    for key, specificTypesAndNames in pairs(typesAndNames) do
        local types = specificTypesAndNames[1]
        local typeNames = specificTypesAndNames[2]
        for i, thisType in pairs(types) do
            if thisType == type then
                return typeNames[i]
            end
        end
    end
    LogError("Could not convert type \"" .. type .. "\" to typename.")
    return "TYPENAME NOT FOUND"
end

local function addPrimaryEntitiesLocationsToRefs()
    local primaryEntities = GetPrimaryRefEntities(Entities)
    for label, entity in pairs(primaryEntities) do
        local location = entity["location"]
        if location ~= nil then
            AddRef(location, PrimaryRefs)
        end
    end
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
    for label, char in pairs(entityMap) do
        local targetLabel = char[keyword]
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
                Entities[targetLabel][name][#Entities[targetLabel][name] + 1] = TexCmd("myref", label)
            end
        end
    end
end

local function addAllEntitiesTo()
    for key1, type in pairs({ "npc" }) do
        for key2, keyword in pairs({ "location", "association" }) do
            addEntitiesTo(type, keyword)
        end
    end
end

function AddAutomatedDescriptors()
    AddHistoryDescriptors()
    addAllEntitiesTo()
    AddSpeciesAndAgeStringToNPCs()
end

function ComplementRefs()
    AddPrimaryPlaceNPCsToRefs()
    AddPrimaryPlaceParentsToRefs()
    addPrimaryEntitiesLocationsToRefs()
    local primaryEntities = GetPrimaryRefEntities(Entities)
    ScanContentForSecondaryRefs(primaryEntities)
    ReplaceMyrefWithNameref(primaryEntities)
end

dofile(RelativePath .. "entities-geography.lua")
dofile(RelativePath .. "entities-characters.lua")
dofile(RelativePath .. "entities-associations.lua")
dofile(RelativePath .. "entities-languages.lua")
dofile(RelativePath .. "entities-items.lua")
dofile(RelativePath .. "entities-history.lua")
dofile(RelativePath .. "entities-print.lua")
dofile(RelativePath .. "entities-tex-api.lua")
