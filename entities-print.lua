local function extractEntitiesAtLocation(list, location)
    StartBenchmarking("extractEntitiesAtLocation")
    local out = {}
    for key, entity in pairs(list) do
        if entity["location"] == location or (IsEmpty(entity["location"]) and IsEmpty(location)) then
            out[#out + 1] = entity
        end
    end
    StopBenchmarking("extractEntitiesAtLocation")
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
    local out = {}
    for index, key in pairs(keys) do
        local content = map[key]
        if not IsEmpty(content) then
            Append(out, TexCmd("subparagraph", key))
            Append(out, content)
        end
    end
    return table.concat(out)
end

function DescriptorsString(entity)
    StartBenchmarking("DescriptorsString")
    local out = {}

    local descriptorsList = {}
    for descriptor, description in pairs(entity) do
        if not IsIn(descriptor, ProtectedDescriptors) then
            descriptorsList[#descriptorsList + 1] = descriptor
        end
    end
    table.sort(descriptorsList)
    for key, descriptor in pairs(descriptorsList) do
        Append(out, TexCmd("paragraph", CapFirst(descriptor)))
        if descriptor == Tr("history") then
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
    StopBenchmarking("DescriptorsString")
    return out
end

local function printEntities(sectionname, entitiesList)
    StartBenchmarking("printEntities")
    local out = {}
    if IsEmpty(entitiesList) then
        StopBenchmarking("printEntities")
        return out
    end
    Append(out, TexCmd("subsection", sectionname))
    table.sort(entitiesList, CompareByName)
    for key, entity in pairs(entitiesList) do
        Append(out, TexCmd("subsubsection", entity["name"], entity["shortname"]))
        Append(out, TexCmd("label", GetMainLabel(entity)))
        Append(out, DescriptorsString(entity))
    end
    StopBenchmarking("printEntities")
    return out
end

function PrintOnlyMentionedChapter()
    local out = {}
    local secondaryEntities = GetEntitiesIf(IsSecondary, AllEntities)
    if #secondaryEntities > 0 then
        Append(out, TexCmd("chapter", CapFirst(Tr("only-mentioned"))))
        table.sort(secondaryEntities, CompareByName)
        for index, entity in pairs(secondaryEntities) do
            Append(out, TexCmd("subparagraph", GetShortname(entity)))
            for key, label in pairs(GetLabels(entity)) do
                Append(out, TexCmd("label", label))
            end
            Append(out, TexCmd("hspace", "1cm"))
        end
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
    Append(out, TexCmd("chapter", CapFirst(name)))
    if not IsEmpty(primaryEntities) then
        Append(out, TexCmd("section*", CapFirst(Tr("all")) .. " " .. CapFirst(name)))
        Append(out, ListAll(getAllLabels(primaryEntities), NamerefString))
    end
    return out
end

local function printEntityChapterSortedByLocation(primaryEntities)
    StartBenchmarking("printEntityChapterSortedByLocation")
    local sectionname = Tr("in-whole-world")
    local entitiesWorldwide = extractEntitiesAtLocation(primaryEntities, nil)
    local out = printEntities(sectionname, entitiesWorldwide)

    for index, locationLabel in pairs(AllLocationLabelsSorted()) do
        local location = GetEntity(locationLabel)
        local sectionname = CapFirst(Tr("in")) .. " " .. PlaceToName(location)
        local entitiesHere = extractEntitiesAtLocation(primaryEntities, locationLabel)
        Append(out, printEntities(sectionname, entitiesHere))
    end

    local sectionname = Tr("at-unknown-locations")
    local entitiesSomewhere = GetEntitiesIf(IsLocationUnknown, primaryEntities)
    Append(out, printEntities(sectionname, entitiesSomewhere))

    StopBenchmarking("printEntityChapterSortedByLocation")
    return out
end

function PrintEntityChapter(primaryEntities, name, types)
    StartBenchmarking("PrintEntityChapter")
    local isOfFittingType = Bind(IsType, types)
    local fittingEntities = GetEntitiesIf(isOfFittingType, primaryEntities)
    local out = {}
    if IsEmpty(fittingEntities) then
        StopBenchmarking("PrintEntityChapter")
        return out
    end

    Append(out, PrintEntityChapterBeginning(name, fittingEntities))
    for i, type in pairs(types) do
        local entitiesOfType = GetEntitiesOfType(type, fittingEntities)
        if not IsEmpty(entitiesOfType) then
            Append(out, TexCmd("section", CapFirst(Tr(type))))
            Append(out, printEntityChapterSortedByLocation(entitiesOfType))
        end
    end
    StopBenchmarking("PrintEntityChapter")
    return out
end
