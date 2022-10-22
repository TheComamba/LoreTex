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
    if type(entity) == "string" then
        entity = GetEntity(entity)
    end
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
    table.sort(keys, StrCmp)
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
    table.sort(descriptorsList, StrCmp)
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
    Append(out, TexCmd("subsection", CapFirst(sectionname)))
    table.sort(entitiesList, CompareByName)
    for key, entity in pairs(entitiesList) do
        Append(out, TexCmd("subsubsection", entity["name"], entity["shortname"]))
        Append(out, TexCmd("label", GetMainLabel(entity)))
        Append(out, DescriptorsString(entity))
    end
    StopBenchmarking("printEntities")
    return out
end

function PrintOnlyMentionedChapter(mentionedRefs)
    StartBenchmarking("PrintOnlyMentionedChapter")
    local out = {}
    if IsEmpty(mentionedRefs) then
        StopBenchmarking("PrintOnlyMentionedChapter")
        return out
    end
    Append(out, TexCmd("chapter", CapFirst(Tr("only-mentioned"))))
    table.sort(mentionedRefs, CompareByName)
    for key, label in pairs(mentionedRefs) do
        local entity = GetEntity(label)
        Append(out, TexCmd("subparagraph", GetShortname(entity)))
        for key, label in pairs(GetLabels(entity)) do
            Append(out, TexCmd("label", label))
        end
        Append(out, TexCmd("hspace", "1cm"))
    end
    StopBenchmarking("PrintOnlyMentionedChapter")
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

    local sectionname = Tr("at-secret-locations")
    local entitiesAtSecretLocations = GetEntitiesIf(IsLocationUnrevealed, primaryEntities)
    Append(out, printEntities(sectionname, entitiesAtSecretLocations))

    local sectionname = Tr("at-unfound-locations")
    local entitiesAtUnfoundLocations = GetEntitiesIf(IsLocationUnknown, primaryEntities)
    Append(out, printEntities(sectionname, entitiesAtUnfoundLocations))

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
