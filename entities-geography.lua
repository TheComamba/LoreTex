CurrentCity = ""
CurrentRegion = ""
CurrentContinent = ""
PlaceTypes = { "continent", "region", "city" }
PlaceTypeNames = { "Kontinente", "Regionen", "Städte" }
local placeDepths = { { PlaceTypes[1], "section" },
    { PlaceTypes[2], "subsection" },
    { PlaceTypes[3], "subsubsection" } }

function IsPlace(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], PlaceTypes)
end

function IsLocationUnknown(entity)
    local location = entity["location"]
    if IsEmpty(location) then
        return false
    else
        local err = "Location\""
        err = err .. location
        err = err .. "\" of entity \""
        err = err .. entity["name"]
        if Entities[location] == nil then
            err = err .. "\" not found."
            LogError(err)
            return true
        elseif not IsPlace(Entities[location]) then
            err = err .. "\" is not a place."
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
            for key1, ref in pairs(npcsHere) do
                for key2, label in pairs(ScanForRefs(ref)) do
                    AddRef(label, PrimaryRefs)
                end
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

local function compareLocationLabelsByName(label1, label2)
    local name1 = LocationLabelToName(label1)
    local name2 = LocationLabelToName(label2)
    return name1 < name2
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
    table.sort(placeLabels, compareLocationLabelsByName)

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

    local secondaryRefLabels = GetSecondaryRefEntitiesLabels(places)

    Append(out, PrintOnlyMentionedSection(secondaryRefLabels))
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

function AllLocationLabelsSorted()
    local locations = GetEntitiesIf(IsPlace)
    local labels = {}
    for label, elem in pairs(locations) do
        labels[#labels + 1] = label
    end
    table.sort(labels, compareLocationLabelsByName)
    return labels
end
