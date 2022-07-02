Entities = {}
CurrentLabel = ""
ProtectedDescriptors = { "name", "shortname", "type", "parent", "location", "born", "died", "species", "gender" }
OnlyMentioned = "zzz-nur-erwähnt"

function IsOnlyMentioned(entity)
    return IsIn(OnlyMentioned, entity)
end

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

function GetShortname(label)
    if Entities[label] == nil then
        return "Anderswo"
    elseif Entities[label]["shortname"] ~= nil then
        return Entities[label]["shortname"]
    elseif Entities[label]["name"] ~= nil then
        return Entities[label]["name"]
    else
        return "NO NAME"
    end
end

local function descriptorsStringPrimaryRef(entity)
    local str = ""

    local descriptorsList = {}
    for descriptor, description in pairs(entity) do
        if not IsIn(descriptor, ProtectedDescriptors) then
            descriptorsList[#descriptorsList + 1] = descriptor
        end
    end
    table.sort(descriptorsList)
    for key, descriptor in pairs(descriptorsList) do
        str = str .. TexCmd("paragraph", descriptor)
        if descriptor == HistoryCaption then
            str = str .. ListHistory(entity[descriptor])
        elseif type(entity[descriptor]) == "string" then
            str = str .. entity[descriptor]
        elseif type(entity[descriptor]) == "table" then
            str = str .. ListAllFromMap(entity[descriptor])
        end
    end
    return str
end

function DescriptorsString(entity)
    if IsOnlyMentioned(entity) then
        return TexCmd("hspace", "1cm")
    else
        return descriptorsStringPrimaryRef(entity)
    end
end

local function deleteUnused(list)
    for label, entry in pairs(list) do
        if not IsIn(label, PrimaryRefs) then
            if IsIn(label, SecondaryRefs) then
                list[label]["parent"] = OnlyMentioned
                list[label]["location"] = OnlyMentioned
            else
                list[label] = nil
            end
        end
    end
end

function ComplementRefs()
    AddPrimaryPlaceNPCsToRefs()
    AddPrimaryNPCLocationsToRefs()
    AddPrimaryPlaceParentsToRefs()
    AddHistoryDescriptorsToPrimaryRefs()
    ScanContentForSecondaryRefs(Entities)
    deleteUnused(Entities)
end

dofile("../shared/luatex-for-dnd/entities-characters.lua")
dofile("../shared/luatex-for-dnd/entities-geography.lua")
dofile("../shared/luatex-for-dnd/entities-history.lua")
dofile("../shared/luatex-for-dnd/entities-tex-api.lua")
