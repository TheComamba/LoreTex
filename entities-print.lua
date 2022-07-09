local function getSecondaryRefEntitiesLabels(map)
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
        return "NO NAME"
    end
end

local function descritptorTableString(map)
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
            str = str .. descritptorTableString(entity[descriptor])
        end
    end
    return str
end

local function printEntities(sectionname, entitiesList)
    if not next(entitiesList) then
        return
    end
    tex.print(TexCmd("subsection", sectionname))
    for label, entity in pairs(entitiesList) do
        tex.print(TexCmd("subsubsection", entity["name"], entity["shortname"]))
        tex.print(TexCmd("label", label))
        tex.print(DescriptorsString(entity))
    end
end

function PrintOnlyMentionedSection(entitiesList)
    local secondaryRefLabels = getSecondaryRefEntitiesLabels(entitiesList)
    if #secondaryRefLabels > 0 then
        tex.print(TexCmd("twocolumn"))
        tex.print(TexCmd("section", "Nur erwähnt"))
        table.sort(secondaryRefLabels)
        for index, label in pairs(secondaryRefLabels) do
            tex.print(TexCmd("paragraph", GetShortname(label)))
            tex.print(TexCmd("label", label))
            tex.print(TexCmd("hspace", "1cm"))
        end
        tex.print(TexCmd("onecolumn"))
    end
end

function PrintEntityChapterBeginning(name, primaryEntities)
    tex.print(TexCmd("twocolumn"))
    tex.print(TexCmd("chapter", name))
    tex.print(TexCmd("section*", "Alle " .. name))
    tex.print(ListAllFromMap(primaryEntities))
    tex.print(TexCmd("onecolumn"))
end

local function printEntityChapterSortedByLocation(primaryEntities)
    local sectionname = "In der ganzen Welt"
    local entitiesHere = extractEntitiesAtLocation(primaryEntities, nil)
    printEntities(sectionname, entitiesHere)

    for index, label in pairs(AllLocationLabelsSorted()) do
        local sectionname = "In " .. LocationLabelToName(label)
        local entitiesHere = extractEntitiesAtLocation(primaryEntities, label)
        printEntities(sectionname, entitiesHere)
    end
end

function PrintEntityChapter(name, entitiesList, types)
    local primaryEntities = GetPrimaryRefEntities(entitiesList)
    if IsEmpty(primaryEntities) then
        return
    end

    PrintEntityChapterBeginning(name, primaryEntities)
    for i, type in pairs(types) do
        local entitiesOfType = GetEntitiesOfType(type, primaryEntities)
        if not IsEmpty(entitiesOfType) then
            tex.print(TexCmd("section", TypeToName(type)))
            printEntityChapterSortedByLocation(entitiesOfType)
        end
    end
    PrintOnlyMentionedSection(entitiesList)
end
