function PlaceToName(location)
    local name = ""
    local locationNames = {}
    while location ~= nil do
        local locationName = GetShortname(location)
        if name == "" then
            name = locationName
        else
            name = locationName .. " - " .. name
        end

        if IsIn(locationName, locationNames) then
            Append(locationNames, locationName)
            local err = {}
            Append(err, "Enountered loop! Output is \"")
            Append(err, name)
            Append(err, "\", generated from location labels:")
            Append(err, DebugPrint(locationNames))
            LogError(err)
            break
        else
            Append(locationNames, locationName)
        end
        location = GetProtectedInheritableField(location, "location")
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

function LabelFromName(name)
    local label = name:lower()
    label = Replace(" ", "-", label)
    label = Replace([[\]], "", label)
    label = Replace([[{]], "", label)
    label = Replace([[}]], "", label)
    return label
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
