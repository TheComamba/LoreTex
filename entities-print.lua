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
    Sort(keys, "compareAlphanumerical")
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

local function descriptorsString(entity)
    StartBenchmarking("DescriptorsString")
    local out = {}


    local descriptorsList = {}
    for descriptor, description in pairs(entity) do
        if not IsProtectedDescriptor(descriptor) then
            descriptorsList[#descriptorsList + 1] = descriptor
        end
    end
    Sort(descriptorsList, "compareAlphanumerical")
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
    if IsEmpty(entitiesList) then
        return {}
    end

    StartBenchmarking("printEntities")
    local out = {}
    Append(out, TexCmd("subsection", CapFirst(sectionname)))
    Sort(entitiesList, "compareByName")
    for key, entity in pairs(entitiesList) do
        local shortname = GetProtectedStringField(entity, "shortname")
        if IsEmpty(shortname) then
            Append(out, TexCmd("subsubsection", GetProtectedStringField(entity, "name")))
        else
            Append(out, TexCmd("subsubsection", GetProtectedStringField(entity, "name"), shortname))
        end
        Append(out, TexCmd("label", GetMainLabel(entity)))
        Append(out, descriptorsString(entity))
    end
    StopBenchmarking("printEntities")
    return out
end

function PrintOnlyMentionedChapter(mentionedRefs)
    StartBenchmarking("PrintOnlyMentionedChapter")
    local out = {}
    Sort(mentionedRefs, "compareByName")
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
        UniqueAppend(out, GetProtectedTableField(entity, "labels"))
        UniqueAppend(out, getAllLabels(GetProtectedTableField(entity, "subEntities")))
    end
    return out
end

local function PrintAllEntities(name, entities)
    local out = {}
    local allLabels = {}
    for locationName, entity in pairs(entities) do
        Append(allLabels, getAllLabels(entity))
    end
    Sort(allLabels, "compareByName")
    if not IsEmpty(allLabels) then
        Append(out, TexCmd("subsection*", CapFirst(Tr("all")) .. " " .. CapFirst(name)))
        Append(out, ListAll(allLabels, NamerefString))
    end
    return out
end

local function printEntityChapterSortedByLocation(entities)
    StartBenchmarking("printEntityChapterSortedByLocation")
    local out = {}

    local locationNames = GetSortedKeys(entities)
    for i, locationName in pairs(locationNames) do
        if not IsProtectedDescriptor(locationName) then
            local sectionname = ""
            if IsEmpty(locationName) then
                sectionname = Tr("in-whole-world")
            else
                sectionname = CapFirst(Tr("in")) .. " " .. locationName
            end
            local entitiesHere = entities[locationName]
            Append(out, printEntities(sectionname, entitiesHere))
        end
    end

    local sectionname = Tr("at-secret-locations")
    local entitiesAtSecretLocations = GetProtectedTableField(entities, "isSecret")
    Append(out, printEntities(sectionname, entitiesAtSecretLocations))

    StopBenchmarking("printEntityChapterSortedByLocation")
    return out
end

function PrintEntityChapter(processedOut, metatype)
    if IsEmpty(processedOut.entities[metatype]) then
        return {}
    end

    StartBenchmarking("PrintEntityChapter")
    local out = {}
    Append(out, TexCmd("chapter", CapFirst(Tr(metatype))))
    local types = AllTypes[metatype]
    Sort(types, "compareTranslation")
    for i, type in pairs(types) do
        local entitiesOfType = processedOut.entities[metatype][type]
        if not IsEmpty(entitiesOfType) then
            Append(out, TexCmd("section", CapFirst(Tr(type))))
            Append(out, PrintAllEntities(Tr(type), entitiesOfType))
            Append(out, printEntityChapterSortedByLocation(entitiesOfType))
        end
    end
    StopBenchmarking("PrintEntityChapter")
    return out
end
