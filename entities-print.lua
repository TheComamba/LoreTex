local function extractEntitiesAtLocation(list, location)
    StartBenchmarking("extractEntitiesAtLocation")
    local out = {}
    for key, entity in pairs(list) do
        local entityLocation = GetProtectedNullableField(entity, "location")
        if IsEmpty(entityLocation) and IsEmpty(location) then
            out[#out + 1] = entity
        elseif (not IsEmpty(entityLocation) and not IsEmpty(location)) then
            if GetMainLabel(entityLocation) == GetMainLabel(location) then
                out[#out + 1] = entity
            end
        end
    end
    StopBenchmarking("extractEntitiesAtLocation")
    return out
end

function GetShortname(entity)
    if type(entity) == "string" then
        entity = GetEntity(entity)
    end
    if IsEmpty(entity) then
        return "NIL"
    elseif not IsEmpty(GetProtectedStringField(entity, "shortname")) then
        return GetProtectedStringField(entity, "shortname")
    elseif not IsEmpty(GetProtectedStringField(entity, "name")) then
        return GetProtectedStringField(entity, "name")
    else
        LogError("Entity has no name:" .. DebugPrint(entity))
        return "NO NAME"
    end
end

local function descritptorMapString(map)
    local keys = {}
    for key, elem in pairs(map) do
        keys[#keys + 1] = key
    end
    table.sort(keys, CompareAlphanumerical)
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
        if not IsProtectedDescriptor(descriptor) then
            descriptorsList[#descriptorsList + 1] = descriptor
        end
    end
    table.sort(descriptorsList, CompareAlphanumerical)
    for key, descriptor in pairs(descriptorsList) do
        Append(out, TexCmd("paragraph", CapFirst(descriptor)))
        if descriptor == HeightCaption then
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
        local shortname = GetProtectedStringField(entity, "shortname")
        if IsEmpty(shortname) then
            Append(out, TexCmd("subsubsection", GetProtectedStringField(entity, "name")))
        else
            Append(out, TexCmd("subsubsection", GetProtectedStringField(entity, "name"), shortname))
        end
        Append(out, TexCmd("label", GetMainLabel(entity)))
        Append(out, DescriptorsString(entity))
    end
    StopBenchmarking("printEntities")
    return out
end

function PrintOnlyMentionedChapter(mentionedRefs)
    StartBenchmarking("PrintOnlyMentionedChapter")
    local out = {}
    table.sort(mentionedRefs, CompareByName)
    for key, label in pairs(mentionedRefs) do
        if key == 1 then
            Append(out, TexCmd("chapter", CapFirst(Tr("only-mentioned"))))
        end
        local name = LabelToName(label)
        if not IsEmpty(name) then
            Append(out, TexCmd("subparagraph", name))
            Append(out, TexCmd("label", label))
            Append(out, TexCmd("hspace", "1cm"))
        end
    end
    StopBenchmarking("PrintOnlyMentionedChapter")
    return out
end

local function getAllLabels(list)
    local out = {}
    for key, entity in pairs(list) do
        Append(out, GetProtectedTableField(entity, "labels"))
    end
    return out
end

local function PrintAllEntities(name, entities)
    local out = {}
    local allLabels = getAllLabels(entities)
    table.sort(allLabels, CompareByName)
    if not IsEmpty(allLabels) then
        Append(out, TexCmd("subsection*", CapFirst(Tr("all")) .. " " .. CapFirst(name)))
        Append(out, ListAll(allLabels, NamerefString))
    end
    return out
end

local function getAllLocationsSorted(entities)
    local locations = {}
    local locationLabels = {}
    for key, entity in pairs(entities) do
        local location = GetProtectedNullableField(entity, "location")
        if not IsEmpty(location) and IsEntityShown(location) then
            local locationLabel = GetMainLabel(location)
            if not IsIn(locationLabel, locationLabels) then
                Append(locationLabels, locationLabel)
                locations[#locations + 1] = location
            end
        end
    end
    table.sort(locations, CompareLocationLabelsByName)
    return locations
end

local function printEntityChapterSortedByLocation(entities)
    StartBenchmarking("printEntityChapterSortedByLocation")

    local sectionname = Tr("in-whole-world")
    local entitiesWorldwide = extractEntitiesAtLocation(entities, nil)
    local out = printEntities(sectionname, entitiesWorldwide)

    local locations = getAllLocationsSorted(entities)
    for index, location in pairs(locations) do
        local sectionname = CapFirst(Tr("in")) .. " " .. PlaceToName(location)
        local entitiesHere = extractEntitiesAtLocation(entities, location)
        Append(out, printEntities(sectionname, entitiesHere))
    end

    local sectionname = Tr("at-secret-locations")
    local entitiesAtSecretLocations = GetEntitiesIf(IsLocationUnrevealed, entities)
    Append(out, printEntities(sectionname, entitiesAtSecretLocations))

    StopBenchmarking("printEntityChapterSortedByLocation")
    return out
end

function PrintEntityChapter(primaryEntities, metatype)
    StartBenchmarking("PrintEntityChapter")
    local isOfFittingType = Bind(IsType, metatype)
    local fittingEntities = GetEntitiesIf(isOfFittingType, primaryEntities)
    local out = {}
    if IsEmpty(fittingEntities) then
        StopBenchmarking("PrintEntityChapter")
        return out
    end

    Append(out, TexCmd("chapter", CapFirst(Tr(metatype))))
    local types = AllTypes[metatype]
    table.sort(types, CompareTranslation)
    for i, type in pairs(types) do
        local entitiesOfType = GetEntitiesOfType(type, fittingEntities)
        if not IsEmpty(entitiesOfType) then
            Append(out, TexCmd("section", CapFirst(Tr(type))))
            Append(out, PrintAllEntities(Tr(type), entitiesOfType))
            Append(out, printEntityChapterSortedByLocation(entitiesOfType))
        end
    end
    StopBenchmarking("PrintEntityChapter")
    return out
end
