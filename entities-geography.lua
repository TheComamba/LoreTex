Append(ProtectedDescriptors, {"location"})
DefaultLocation = ""
PlaceTypes = { "place" }
PlaceTypeNames = { "Orte" }

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
