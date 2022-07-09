CurrentCity = ""
CurrentRegion = ""
CurrentContinent = ""
local placeTypes = { "continent", "region", "city" }
local placeDepths = { { placeTypes[1], "section" },
    { placeTypes[2], "subsection" },
    { placeTypes[3], "subsubsection" } }

function IsPlace(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], placeTypes)
end

function IsLocationUnknown(entity)
    local location = entity["location"]
    if IsEmpty(location) then
        return false
    else
        if Entities[location] == nil then
            local err = "Location\""
            err = err .. location
            err = err .. "\" of entity \""
            err = err .. entity["name"]
            err = err .. "\"not found."
            LogError(err)
            return true
        else
            return false
        end
    end
end

function AddPrimaryPlaceNPCsToRefs()
    local places = GetEntitiesIf(IsPlace)
    local primaryPlaces = GetPrimaryRefEntities(places)
    for placeLabel, place in pairs(primaryPlaces) do
        local npcsHere = place["NPCs"]
        if npcsHere ~= nil then
            for label, npc in pairs(npcsHere) do
                AddRef(label, PrimaryRefs)
            end
        end
    end
end

function AddPrimaryPlaceParentsToRefs()
    local places = GetEntitiesIf(IsPlace)
    local primaryPlaces = GetPrimaryRefEntities(places)
    for label, entry in pairs(primaryPlaces) do
        while label ~= nil do
            AddRef(label, PrimaryRefs)
            label = Entities[label]["parent"]
        end
    end
end

local function createGeographyLayer(currentDepth, parent)
    local out = {}
    if currentDepth > #placeDepths then
        return out
    end
    local placeLabels = {}
    for label, place in pairs(Entities) do
        if place["type"] == placeDepths[currentDepth][1] and IsIn(label, PrimaryRefs) then
            if parent == nil or place["parent"] == parent then
                placeLabels[#placeLabels + 1] = label
            end
        end
    end
    table.sort(placeLabels)

    for key, label in pairs(placeLabels) do
        local place = Entities[label]
        local docStructure = placeDepths[currentDepth][2]
        Append(out, TexCmd(docStructure, place["name"], place["shortname"]))
        Append(out, TexCmd("label", label))
        Append(out, DescriptorsString(place))
        Append(out, createGeographyLayer(currentDepth + 1, label))
    end
    return out
end

function CreateGeography()
    local places = GetEntitiesIf(IsPlace)
    local primaryPlaces = GetPrimaryRefEntities(places)
    local out = PrintEntityChapterBeginning("Orte", primaryPlaces)

    Append(out, TexCmd("section", "Yestaiel, die Welt", "Yestaiel"))
    Append(out, TexCmd("label", "yestaiel"))
    Append(out, TexCmd("input", "../shared/geography/yestaiel.tex"))

    Append(out, createGeographyLayer(1))

    PrintOnlyMentionedSection(places)
    return out
end

function LocationLabelToName(label)
    local name = ""
    while label ~= nil do
        if name == "" then
            name = GetShortname(label)
        else
            name = GetShortname(label) .. " - " .. name
        end
        label = Entities[label]["parent"]
    end
    return name
end

local function compareLabelsByFullName(label1, label2)
    local name1 = LocationLabelToName(label1)
    local name2 = LocationLabelToName(label2)
    return name1 < name2
end

function AllLocationLabelsSorted()
    local locations = GetEntitiesIf(IsPlace)
    local labels = {}
    for label, elem in pairs(locations) do
        labels[#labels + 1] = label
    end
    table.sort(labels, compareLabelsByFullName)
    return labels
end
