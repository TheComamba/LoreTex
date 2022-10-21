Append(ProtectedDescriptors, { "location" })
DefaultLocation = ""
PlaceTypes = { "places" }
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
        local err = {}
        Append(err, "Location\"")
        Append(err, locationLabel)
        Append(err, "\" of entity \"")
        Append(err, entity["name"])
        if IsEmpty(location) then
            Append(err, "\" not found.")
            LogError(table.concat(err))
            return true
        elseif not IsPlace(location) then
            Append(err, "\" is not a place.")
            LogError(table.concat(err))
            return true
        else
            return false
        end
    end
end

local function getLocation(entity)
    local locationLabel = entity["location"]
    if IsEmpty(locationLabel) then
        return {}
    elseif IsIn(locationLabel, GetLabels(entity)) then
        LogError(locationLabel .. " is listed as location of " .. GetMainLabel(entity) .. " itself!")
        return {}
    else
        return GetEntity(locationLabel)
    end
end

function IsLocationUnrevealed(entity)
    local location = getLocation(entity)
    return IsSecret(location) and (not IsRevealed(location))
end

local function compareLocationLabelsByName(label1, label2)
    local entity1 = GetEntity(label1)
    local entity2 = GetEntity(label2)
    local name1 = PlaceToName(entity1)
    local name2 = PlaceToName(entity2)
    return StrCmp(name1, name2)
end

function PlaceToName(place)
    local name = ""
    while not IsEmpty(place) do
        if name == "" then
            name = GetShortname(place)
        else
            name = GetShortname(place) .. " - " .. name
        end
        place = getLocation(place)
    end
    return name
end

function AllLocationLabelsSorted()
    StartBenchmarking("AllLocationLabelsSorted")
    local places = GetEntitiesIf(IsPlace, AllEntities)
    local labels = {}
    for key, place in pairs(places) do
        labels[#labels + 1] = GetMainLabel(place)
    end
    table.sort(labels, compareLocationLabelsByName)
    StopBenchmarking("AllLocationLabelsSorted")
    return labels
end
