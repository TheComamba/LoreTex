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

function GetPrimaryRefEntities(map)
    local out = {}
    for label, elem in pairs(map) do
        if IsIn(label, PrimaryRefs) then
            out[label] = elem
        end
    end
    return out
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
dofile("../shared/luatex-for-dnd/entities-history.lua")
dofile("../shared/luatex-for-dnd/entities-print.lua")
dofile("../shared/luatex-for-dnd/entities-tex-api.lua")
