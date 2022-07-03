CurrentCity = ""
CurrentRegion = ""
CurrentContinent = ""
PlaceTypes = { "continent", "region", "city" }
PlaceDepths = { { PlaceTypes[1], "section" },
    { PlaceTypes[2], "subsection" },
    { PlaceTypes[3], "subsubsection" } }

AddRef(OnlyMentioned, PrimaryRefs)
Entities[OnlyMentioned] = {}
Entities[OnlyMentioned]["name"] = "Nur erwähnt"
Entities[OnlyMentioned]["type"] = PlaceTypes[1]

function IsPlace(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], PlaceTypes)
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
    if currentDepth > #PlaceDepths then
        return
    end
    local placeLabels = {}
    for label, place in pairs(Entities) do
        if place["type"] == PlaceDepths[currentDepth][1] or parent == OnlyMentioned then
            if parent == nil or place["parent"] == parent then
                placeLabels[#placeLabels + 1] = label
            end
        end
    end
    table.sort(placeLabels)

    for key, label in pairs(placeLabels) do
        local place = Entities[label]
        local str = ""
        local docStructure = PlaceDepths[currentDepth][2]
        if place["parent"] ~= nil and place["parent"] == OnlyMentioned then
            docStructure = "paragraph"
        end
        str = str .. TexCmd(docStructure, place["name"], place["shortname"])
        str = str .. TexCmd("label", label)
        str = str .. DescriptorsString(place)
        tex.print(str)
        createGeographyLayer(currentDepth + 1, label)
    end
end

function CreateGeography()
    tex.print(TexCmd("twocolumn"))
    tex.print(TexCmd("chapter", "Orte"))
    tex.print(TexCmd("section", "Alle Orte, alphabetisch sortiert"))
    local places = GetEntitiesIf(IsPlace)
    tex.print(ListAllFromMap(places))
    tex.print(TexCmd("onecolumn"))

    tex.print(TexCmd("section", "Yestaiel, die Welt", "Yestaiel"))
    tex.print(TexCmd("label", "yestaiel"))
    tex.print(TexCmd("input", "../shared/geography/yestaiel.tex"))

    createGeographyLayer(1)
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
