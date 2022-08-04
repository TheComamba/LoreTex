Append(ProtectedDescriptors, {"parent", "location"})
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
    local locationLabel = entity["location"]
    if IsEmpty(locationLabel) then
        return false
    else
        local location = GetEntity(locationLabel)
        local err = "Location\""
        err = err .. locationLabel
        err = err .. "\" of entity \""
        err = err .. entity["name"]
        if IsEmpty(location) then
            err = err .. "\" not found."
            LogError(err)
            return true
        elseif not IsPlace(location) then
            err = err .. "\" is not a place."
            LogError(err)
            return true
        else
            return false
        end
    end
end

local function getParent(entity)
    local parentLabel = entity["parent"]
    if IsEmpty(parentLabel) then
        return {}
    else
        return GetEntity(parentLabel)
    end
end

local function getChildren(entity)
    local parentLabel = nil
    if not IsEmpty(entity) then
        parentLabel = GetMainLabel(entity)
    end
    local places = GetEntitiesIf(IsPlace)
    local out = {}
    for key, place in pairs(places) do
        if place["parent"] == parentLabel then
            out[#out+1] = place
        end
    end
    return out
end

function AddPrimaryPlaceParentsToRefs()
    local places = GetEntitiesIf(IsPlace)
    local primaryPlaces = GetEntitiesIf(IsPrimary, places)
    for key, entity in pairs(primaryPlaces) do
        while not IsEmpty(entity) do
            local labels = GetLabels(entity)
            AddRef(labels, PrimaryRefs)
            entity = getParent(entity)
        end
    end
end

local function compareLocationLabelsByName(label1, label2)
    local entity1 = GetEntity(label1)
    local entity2 = GetEntity(label2)
    local name1 = PlaceToName(entity1)
    local name2 = PlaceToName(entity2)
    return name1 < name2
end

local function createGeographyLayer(currentDepth, parent)
    local out = {}
    local children = getChildren(parent)
    children = GetEntitiesIf(IsPrimary, children)
    table.sort(children, CompareByName)
    for key, place in pairs(children) do
        local docStructure = placeDepths[currentDepth][2]
        Append(out, TexCmd(docStructure, place["name"], place["shortname"]))
        Append(out, TexCmd("label", GetMainLabel(place)))
        Append(out, DescriptorsString(place))
        Append(out, createGeographyLayer(currentDepth + 1, place))
    end
    return out
end

function CreateGeography()
    local places = GetEntitiesIf(IsPlace)
    local primaryPlaces = GetEntitiesIf(IsPrimary, places)
    local out = PrintEntityChapterBeginning("Orte", primaryPlaces)

    Append(out, TexCmd("section", "Yestaiel, die Welt", "Yestaiel"))
    Append(out, TexCmd("label", "yestaiel"))
    Append(out, TexCmd("input", "../shared/geography/yestaiel.tex"))

    Append(out, createGeographyLayer(1))

    local secondaryEntities = GetEntitiesIf(IsSecondary, places)
    Append(out, PrintOnlyMentionedSection(secondaryEntities))
    return out
end

function PlaceToName(place)
    local name = ""
    while not IsEmpty(place) do
        if name == "" then
            name = GetShortname(place)
        else
            name = GetShortname(place) .. " - " .. name
        end
        place = getParent(place)
    end
    return name
end

function AllLocationLabelsSorted()
    local places = GetEntitiesIf(IsPlace)
    local labels = {}
    for key, place in pairs(places) do
        labels[#labels + 1] = GetMainLabel(place)
    end
    table.sort(labels, compareLocationLabelsByName)
    return labels
end
