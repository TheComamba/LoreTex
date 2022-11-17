local function extractEntitiesAtLocation(list, location)
    StartBenchmarking("extractEntitiesAtLocation")
    local out = {}
    for key, entity in pairs(list) do
        local entityLocation = GetProtectedField(entity, "location")
        if entityLocation == location or (IsEmpty(entityLocation) and IsEmpty(location)) then
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
    if IsEmpty(entity) then
        return "NIL"
    elseif not IsEmpty(GetProtectedField(entity, "shortname")) then
        return GetProtectedField(entity, "shortname")
    elseif not IsEmpty(GetProtectedField(entity, "name")) then
        return GetProtectedField(entity, "name")
    else
        LogError("Entity " .. DebugPrint(entity) .. " has no name.")
        return "NO NAME"
    end
end

function LabelToName(label)
    local entity = GetEntity(label)
    if label == GetMainLabel(entity) then
        return GetShortname(entity)
    else
        for paragraph, content in pairs(entity) do
            local foundLabels = ScanForCmd(content, "label")
            local labelIndex = nil
            for ind, someLabel in pairs(foundLabels) do
                if someLabel == label then
                    labelIndex = ind
                    break
                end
            end
            if labelIndex ~= nil then
                local subparagraphs = ScanForCmd(content, "subparagraph")
                if #foundLabels == #subparagraphs then
                    return subparagraphs[labelIndex]
                else
                    return paragraph
                end
            end
        end
    end
    if not IsIn(label, UnfoundRefs) then
        LogError("Label \"" .. label .. "\" not found.")
        Append(UnfoundRefs, label)
    end
    return label:upper()
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
        local shortname = GetProtectedField(entity, "shortname")
        if IsEmpty(shortname) then
            Append(out, TexCmd("subsubsection", GetProtectedField(entity, "name")))
        else
            Append(out, TexCmd("subsubsection", GetProtectedField(entity, "name"), shortname))
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
        Append(out, GetLabels(entity))
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

local function getAllLocationLabelsSorted(entities)
    local locationLabels = {}
    for key, entity in pairs(entities) do
        local locationLabel = GetProtectedField(entity, "location")
        if not IsEmpty(locationLabel) then
            if IsEntityShown(GetEntity(locationLabel)) then
                UniqueAppend(locationLabels, locationLabel)
            end
        end
    end
    table.sort(locationLabels, CompareLocationLabelsByName)
    return locationLabels
end

local function printEntityChapterSortedByLocation(entities)
    StartBenchmarking("printEntityChapterSortedByLocation")

    local sectionname = Tr("in-whole-world")
    local entitiesWorldwide = extractEntitiesAtLocation(entities, nil)
    local out = printEntities(sectionname, entitiesWorldwide)

    local locationLabels = getAllLocationLabelsSorted(entities)
    for index, locationLabel in pairs(locationLabels) do
        local location = GetEntity(locationLabel)
        local sectionname = CapFirst(Tr("in")) .. " " .. PlaceToName(locationLabel)
        local entitiesHere = extractEntitiesAtLocation(entities, locationLabel)
        Append(out, printEntities(sectionname, entitiesHere))
    end

    local sectionname = Tr("at-secret-locations")
    local entitiesAtSecretLocations = GetEntitiesIf(IsLocationUnrevealed, entities)
    Append(out, printEntities(sectionname, entitiesAtSecretLocations))

    local sectionname = Tr("at-unfound-locations")
    local entitiesAtUnfoundLocations = GetEntitiesIf(IsLocationUnknown, entities)
    Append(out, printEntities(sectionname, entitiesAtUnfoundLocations))

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
