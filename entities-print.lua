local function extractEntitiesAtLocation(list, location)
    local out = {}
    for key, entity in pairs(list) do
        if entity["location"] == location then
            out[#out+1] = entity
        end
    end
    return out
end

function GetShortname(entity)
    if entity == nil then
        return "NIL"
    elseif entity["shortname"] ~= nil then
        return entity["shortname"]
    elseif entity["name"] ~= nil then
        return entity["name"]
    else
        LogError("Entity " .. DebugPrint(entity) .. " has no name.")
        return "NO NAME"
    end
end

local function descritptorMapString(map)
    local keys = {}
    for key, elem in pairs(map) do
        keys[#keys + 1] = key
    end
    table.sort(keys)
    local str = ""
    for index, key in pairs(keys) do
        local content = map[key]
        if not IsEmpty(content) then
            str = str .. TexCmd("subparagraph", key) .. content
        end
    end
    return str
end

function DescriptorsString(entity)
    local out = {}

    local descriptorsList = {}
    for descriptor, description in pairs(entity) do
        if not IsIn(descriptor, ProtectedDescriptors) then
            descriptorsList[#descriptorsList + 1] = descriptor
        end
    end
    table.sort(descriptorsList)
    for key, descriptor in pairs(descriptorsList) do
        Append(out, TexCmd("paragraph", descriptor))
        if descriptor == HistoryCaption then
            Append(out, ListHistory(entity[descriptor]))
        elseif descriptor == HeightCaption then
            Append(out, HeightDescriptor(entity[descriptor]))
        elseif type(entity[descriptor]) == "string" then
            Append(out, entity[descriptor])
        elseif IsList(entity[descriptor]) then
            Append(out, ListAll(entity[descriptor]))
        elseif IsMap(entity[descriptor]) then
            Append(out, descritptorMapString(entity[descriptor]))
        end
    end
    return out
end

local function printEntities(sectionname, entitiesList)
    local out = {}
    if IsEmpty(entitiesList) then
        return out
    end
    Append(out, TexCmd("subsection", sectionname))
    table.sort(entitiesList, CompareByName)
    for key, entity in pairs(entitiesList) do
        Append(out, TexCmd("subsubsection", entity["name"], entity["shortname"]))
        Append(out, TexCmd("label", GetMainLabel(entity)))
        Append(out, DescriptorsString(entity))
    end
    return out
end

function PrintOnlyMentionedSection(secondaryEntities)
    local out = {}
    if #secondaryEntities > 0 then
        Append(out, TexCmd("twocolumn"))
        Append(out, TexCmd("section", "Nur erwähnt"))
        table.sort(secondaryEntities, CompareByName)
        for index, entity in pairs(secondaryEntities) do
            Append(out, TexCmd("paragraph", GetShortname(entity)))
            for key, label in pairs(GetLabels(entity)) do
                Append(out, TexCmd("label", label))
            end
            Append(out, TexCmd("hspace", "1cm"))
        end
        Append(out, TexCmd("onecolumn"))
    end
    return out
end

local function getAllLabels(list)
    local out = {}
    for key, entity in pairs(list) do
        Append(out, GetLabels(entity))
    end
    return out
end

function PrintEntityChapterBeginning(name, primaryEntities)
    local out = {}
    Append(out, TexCmd("twocolumn"))
    Append(out, TexCmd("chapter", name))
    Append(out, TexCmd("section*", "Alle " .. name))
    Append(out, ListAll(getAllLabels(primaryEntities), NamerefString))
    Append(out, TexCmd("onecolumn"))
    return out
end

local function printEntityChapterSortedByLocation(primaryEntities)
    local sectionname = "In der ganzen Welt"
    local entitiesWorldwide = extractEntitiesAtLocation(primaryEntities, nil)
    local out = printEntities(sectionname, entitiesWorldwide)

    for index, locationLabel in pairs(AllLocationLabelsSorted()) do
        local location = GetEntity(locationLabel)
        local sectionname = "In " .. PlaceToName(location)
        local entitiesHere = extractEntitiesAtLocation(primaryEntities, locationLabel)
        Append(out, printEntities(sectionname, entitiesHere))
    end

    local sectionname = "An mysteriösen Orten"
    local entitiesSomewhere = GetEntitiesIf(IsLocationUnknown, primaryEntities)
    Append(out, printEntities(sectionname, entitiesSomewhere))

    return out
end

function PrintEntityChapter(name, entitiesList, types)
    local primaryEntities = GetEntitiesIf(IsPrimary, entitiesList)
    local secondaryEntities = GetEntitiesIf(IsSecondary, entitiesList)

    local out = {}
    if IsEmpty(primaryEntities) and IsEmpty(secondaryEntities) then
        return out
    end

    Append(out, PrintEntityChapterBeginning(name, primaryEntities))
    for i, type in pairs(types) do
        local entitiesOfType = GetEntitiesOfType(type, primaryEntities)
        if not IsEmpty(entitiesOfType) then
            Append(out, TexCmd("section", TypeToName(type)))
            Append(out, printEntityChapterSortedByLocation(entitiesOfType))
        end
    end
    Append(out, PrintOnlyMentionedSection(secondaryEntities))
    return out
end
