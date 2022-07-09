Entities = {}
CurrentLabel = ""
ProtectedDescriptors = { "name", "shortname", "type", "parent", "location", "born", "died", "species", "gender" }

function GetEntitiesIf(condition)
    local out = {}
    for key, entity in pairs(Entities) do
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
    for key, entity in pairs(Entities) do
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
    typesAndNames[#typesAndNames + 1] = { OrganisationTypes, OrganisationTypeNames }
    for key, specificTypesAndNames in pairs(typesAndNames) do
        local types = specificTypesAndNames[1]
        local typeNames = specificTypesAndNames[2]
        for i, thisType in pairs(types) do
            if thisType == type then
                return typeNames[i]
            end
        end
    end
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

function AddAutomatedDescriptors()
    AddHistoryDescriptors()
    AddNPCsToPlaces()
    AddSpeciesAndAgeStringToNPCs()
end

function ComplementRefs()
    AddPrimaryPlaceNPCsToRefs()
    AddPrimaryPlaceParentsToRefs()
    addPrimaryEntitiesLocationsToRefs()
    ScanContentForSecondaryRefs(Entities)
end

dofile("../shared/luatex-for-dnd/entities-geography.lua")
dofile("../shared/luatex-for-dnd/entities-characters.lua")
dofile("../shared/luatex-for-dnd/entities-organisations.lua")
dofile("../shared/luatex-for-dnd/entities-languages.lua")
dofile("../shared/luatex-for-dnd/entities-items.lua")
dofile("../shared/luatex-for-dnd/entities-history.lua")
dofile("../shared/luatex-for-dnd/entities-print.lua")
dofile("../shared/luatex-for-dnd/entities-tex-api.lua")
