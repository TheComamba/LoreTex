function IsLocationUnrevealed(entity)
    if IsShowSecrets then
        return false
    end
    local location = GetProtectedField(entity, "location")
    return IsEntitySecret(location) and (not IsRevealed(location))
end

function PlaceToName(locationLabel)
    StartBenchmarking("PlaceToName")
    local name = ""
    local locationLabels = {}
    local location = GetEntity(locationLabel)
    while not IsEmpty(location) do
        locationLabel = GetMainLabel(location)
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
        location = GetProtectedField(location, "location")
    end
    StopBenchmarking("PlaceToName")
    return name
end
