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
        Append(out, TexCmd("label", GetProtectedStringField(entity, "label")))
        Append(out, descriptorsString(entity))
    end
    StopBenchmarking("printEntities")
    return out
end

local function withoutDiplicatesOrProcessed(entities)
    local out = {}
    local labels = {}
    for key, entity in pairs(entities) do
        local label = GetProtectedStringField(entity, "label")
        if not IsEmpty(label) and not IsIn(label, labels) then
            Append(labels, label)
            if not IsEntityProcessed(label) then
                out[#out + 1] = entity
            end
        end
    end
    return out
end

function PrintOnlyMentionedChapter(mentionedEntities)
    StartBenchmarking("PrintOnlyMentionedChapter")
    local out = {}
    mentionedEntities = withoutDiplicatesOrProcessed(mentionedEntities)
    Sort(mentionedEntities, "compareByName")
    for key, mentionedEntity in pairs(mentionedEntities) do
        if key == 1 then
            Append(out, TexCmd("chapter", CapFirst(Tr("only-mentioned"))))
        end
        local name = GetProtectedStringField(mentionedEntity, "name")
        local label = GetProtectedStringField(mentionedEntity, "label")
        if not IsEmpty(name) then
            Append(out, TexCmd("subparagraph", name))
            Append(out, TexCmd("label", label))
            Append(out, TexCmd("hspace", "1cm"))
        end
    end
    StopBenchmarking("PrintOnlyMentionedChapter")
    return out
end

local function PrintAllEntities(name, entities)
    local out = {}
    local allLabels = {}
    for locationName, entity in pairs(entities) do
        Append(allLabels, GetAllLabels(entity))
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
