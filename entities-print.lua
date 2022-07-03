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

local function printEntities(sectionname, entitiesList)
    if not next(entitiesList) then
        return
    end
    tex.print(TexCmd("section", sectionname))
    for label, entity in pairs(entitiesList) do
        tex.print(TexCmd("subsection", entity["name"], entity["shortname"]))
        tex.print(TexCmd("label", label))
        tex.print(DescriptorsString(entity))
    end
end

function PrintEntityChapterSortedByLocation(name, entitiesList)
    local primaryEntities = GetPrimaryRefEntities(entitiesList)
    if not next(primaryEntities) then
        return
    end

    tex.print(TexCmd("twocolumn"))
    tex.print(TexCmd("chapter", name))
    tex.print(TexCmd("section*", "Alle " .. name))
    tex.print(ListAllFromMap(primaryEntities))
    tex.print(TexCmd("onecolumn"))

    local sectionname = "In der ganzen Welt"
    local entitiesHere = extractEntitiesAtLocation(primaryEntities, nil)
    printEntities(sectionname, entitiesHere)

    for index, label in pairs(AllLocationLabelsSorted()) do
        local sectionname = "In " .. LocationLabelToName(label)
        local entitiesHere = extractEntitiesAtLocation(primaryEntities, label)
        printEntities(sectionname, entitiesHere)
    end

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
