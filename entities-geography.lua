function IsLocationUnknown(entity)
    local locationLabel = entity["location"]
    if IsEmpty(locationLabel) then
        return false
    end
    local location = GetEntity(locationLabel)
    if IsEmpty(location) then
        local err = {}
        Append(err, "Location\"")
        Append(err, locationLabel)
        Append(err, "\" of entity \"")
        Append(err, GetMainLabel(entity))
        Append(err, "\" not found.")
        LogError(table.concat(err))
        return true
    end
    return false
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
    StartBenchmarking("PlaceToName")
    local name = ""
    local locationLabels = {}
    while not IsEmpty(locationLabel) do
        if name == "" then
            name = LabelToName(locationLabel)
        else
            name = LabelToName(locationLabel) .. " - " .. name
        end

        if IsIn(locationLabel, locationLabels) then
            Append(locationLabels, locationLabel)
            local err = {}
            Append(err, "Enountered loop! Output is \"")
            Append(err, name)
            Append(err, "\", generated from location labels:")
            Append(err, DebugPrint(locationLabels))
            LogError(err)
            break
        else
            Append(locationLabels, locationLabel)
        end

        local place = GetEntity(locationLabel)
        locationLabel = place["location"]
    end
    StopBenchmarking("PlaceToName")
    return name
end
