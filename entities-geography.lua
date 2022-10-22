Append(ProtectedDescriptors, { "location" })
DefaultLocation = ""

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
        elseif not IsType("places", location) then
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
    if IsShowSecrets then
        return false
    end
    local location = getLocation(entity)
    return IsEntitySecret(location) and (not IsRevealed(location))
end

function CompareLocationLabelsByName(label1, label2)
    local name1 = PlaceToName(label1)
    local name2 = PlaceToName(label2)
    return StrCmp(name1, name2)
end

function PlaceToName(locationLabel)
    local name = ""
    while not IsEmpty(locationLabel) do
        if name == "" then
            name = LabelToName(locationLabel)
        else
            name = LabelToName(locationLabel) .. " - " .. name
        end
        local place = GetEntity(locationLabel)
        locationLabel = place["location"]
    end
    return name
end
