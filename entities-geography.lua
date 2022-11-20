function IsLocationUnrevealed(entity)
    if IsShowSecrets then
        return false
    end
    local location = GetProtectedNullableField(entity, "location")
    return IsEntitySecret(location) and (not IsRevealed(location))
end

function PlaceToName(location)
    StartBenchmarking("PlaceToName")
    local name = ""
    local locationLabels = {}
    while not IsEmpty(location) do
        local locationLabel = GetProtectedStringField(location, "label")
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
        location = GetProtectedNullableField(location, "location")
    end
    StopBenchmarking("PlaceToName")
    return name
end
