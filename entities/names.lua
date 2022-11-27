function PlaceToName(location)
    local name = ""
    local locationLabels = {}
    while location ~= nil do
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
    return name
end

function LabelToName(label)
    if label == "" then
        return ""
    end

    local name = ""
    local entity = GetEntityRaw(label)
    if entity ~= nil then
        name = GetProtectedStringField(entity, "name")
    elseif not IsIn(label, UnfoundRefs) then
        LogError("Label \"" .. label .. "\" not found.")
        Append(UnfoundRefs, label)
        name = label:upper()
    end
    return name
end

function GetName(entity)
    local name = GetProtectedStringField(entity, "name")
    if name ~= "" then
        return name
    else
        local label = GetProtectedStringField(entity, "label")
        if label == "" then
            LogError("Entity has neither label nor name:" .. DebugPrint(entity))
            return "NO NAME"
        else
            if not IsIn(label, UnfoundRefs) then
                LogError("Entity without a name: \"" .. label .. "\"")
                Append(UnfoundRefs, label)
            end
            return label:upper()
        end
    end
end

function GetShortname(entity)
    local shortname = GetProtectedStringField(entity, "shortname")
    if shortname ~= "" then
        return shortname
    end
    return GetName(entity)
end
