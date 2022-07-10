function GetSecondaryRefEntitiesLabels(map)
    local out = {}
    for label, elem in pairs(map) do
        if IsIn(label, SecondaryRefs) then
            out[#out + 1] = label
        end
    end
    return out
end

local function extractEntitiesAtLocation(map, location)
    local out = {}
    for label, elem in pairs(map) do
        if elem["location"] == location then
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
        LogError("Entity \"" .. label .. "\" has no name.")
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
    if not next(entitiesList) then
        return out
    end
    Append(out, TexCmd("subsection", sectionname))
    for label, entity in pairs(entitiesList) do
        Append(out, TexCmd("subsubsection", entity["name"], entity["shortname"]))
        Append(out, TexCmd("label", label))
        Append(out, DescriptorsString(entity))
    end
    return out
end

function PrintOnlyMentionedSection(secondaryRefLabels)
    local out = {}
    if #secondaryRefLabels > 0 then
        Append(out, TexCmd("twocolumn"))
        Append(out, TexCmd("section", "Nur erwähnt"))
        table.sort(secondaryRefLabels)
        for index, label in pairs(secondaryRefLabels) do
            Append(out, TexCmd("paragraph", GetShortname(label)))
            Append(out, TexCmd("label", label))
            Append(out, TexCmd("hspace", "1cm"))
        end
        Append(out, TexCmd("onecolumn"))
    end
    return out
end

function PrintEntityChapterBeginning(name, primaryEntities)
    local out = {}
    Append(out, TexCmd("twocolumn"))
    Append(out, TexCmd("chapter", name))
    Append(out, TexCmd("section*", "Alle " .. name))
    Append(out, ListAllFromMap(primaryEntities))
    Append(out, TexCmd("onecolumn"))
    return out
end

local function printEntityChapterSortedByLocation(primaryEntities)
    local sectionname = "In der ganzen Welt"
    local entitiesWorldwide = extractEntitiesAtLocation(primaryEntities, nil)
    local out = printEntities(sectionname, entitiesWorldwide)

    for index, label in pairs(AllLocationLabelsSorted()) do
        local sectionname = "In " .. LocationLabelToName(label)
        local entitiesHere = extractEntitiesAtLocation(primaryEntities, label)
        Append(out, printEntities(sectionname, entitiesHere))
    end

    local sectionname = "An mysteriösen Orten"
    local entitiesSomewhere = GetEntitiesIf(IsLocationUnknown, primaryEntities)
    Append(out, printEntities(sectionname, entitiesSomewhere))

    return out
end

function PrintEntityChapter(name, entitiesList, types)
    local primaryEntities = GetPrimaryRefEntities(entitiesList)
    local secondaryRefLabels = GetSecondaryRefEntitiesLabels(entitiesList)

    local out = {}
    if IsEmpty(primaryEntities) and IsEmpty(secondaryRefLabels) then
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
    Append(out, PrintOnlyMentionedSection(secondaryRefLabels))
    return out
end
