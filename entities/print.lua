local function printEntities(sectionname, entitiesList)
    if IsEmpty(entitiesList) then
        return {}
    end

    local out = {}
    Append(out, TexCmd("subsection", CapFirst(sectionname)))
    Sort(entitiesList, "compareByName")
    for key, entity in pairs(entitiesList) do
        local shortname = GetProtectedStringField(entity, "shortname")
        if shortname == "" then
            Append(out, TexCmd("subsubsection", GetProtectedStringField(entity, "name")))
        else
            Append(out, TexCmd("subsubsection", GetProtectedStringField(entity, "name"), shortname))
        end
        Append(out, TexCmd("label", GetProtectedStringField(entity, "label")))
        Append(out, DescriptorsString(entity))
    end
    return out
end

local function withoutDuplicatesOrProcessed(entities)
    local out = {}
    local labels = {}
    for key, entity in pairs(entities) do
        local label = GetProtectedStringField(entity, "label")
        if label ~= nil and not IsIn(label, labels) then
            Append(labels, label)
            if not IsEntityProcessed(label) then
                out[#out + 1] = entity
            end
        end
    end
    return out
end

function PrintOnlyMentionedChapter(mentionedEntities)
    local out = {}
    mentionedEntities = withoutDuplicatesOrProcessed(mentionedEntities)
    Sort(mentionedEntities, "compareByName")
    for key, mentionedEntity in pairs(mentionedEntities) do
        if key == 1 then
            Append(out, TexCmd("chapter", CapFirst(Tr("only-mentioned"))))
        end
        local name = GetShortname(mentionedEntity)
        local label = GetProtectedStringField(mentionedEntity, "label")
        if name ~= "" then
            Append(out, TexCmd("subparagraph", name))
            Append(out, TexCmd("label", label))
            Append(out, TexCmd("hspace", "1cm"))
        end
    end
    return out
end

local function PrintAllEntities(name, entities)
    local out = {}
    local allLabels = {}
    for locationName, entitiesHere in pairs(entities) do
        for key, entity in pairs(entitiesHere) do
            Append(allLabels, GetAllLabels(entity))
        end
    end
    if #allLabels > 0 then
        Sort(allLabels, "compareByName")
        Append(out, TexCmd("subsection*", CapFirst(Tr("all")) .. " " .. CapFirst(name)))
        Append(out, ListAll(allLabels, NamerefString))
    end
    return out
end

local function printEntityChapterSortedByLocation(entities)
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

    return out
end

function PrintEntityChapter(processedOut, metatype)
    if IsEmpty(processedOut.entities[metatype]) then
        return {}
    end

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
    return out
end
