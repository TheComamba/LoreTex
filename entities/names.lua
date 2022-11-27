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

function LabelToName(label)
    if IsEmpty(label) then
        return ""
    end
    StartBenchmarking("LabelToName")
    local name = ""
    local entity = GetEntityRaw(label)
    if not IsEmpty(entity) then
        name = GetProtectedStringField(entity, "name")
    elseif not IsIn(label, UnfoundRefs) then
        LogError("Label \"" .. label .. "\" not found.")
        Append(UnfoundRefs, label)
        name = label:upper()
    end
    StopBenchmarking("LabelToName")
    return name
end

function GetShortname(entity)
    local shortname = GetProtectedStringField(entity, "shortname")
    if not IsEmpty(shortname) then
        return shortname
    end
    local fullname = GetProtectedStringField(entity, "name")
    if not IsEmpty(fullname) then
        return fullname
    end
    LogError("Entity has no name:" .. DebugPrint(entity))
    return "NO NAME"
end
