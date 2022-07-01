function AddDescriptor(label, descriptor, description)
    if IsStringEmpty(label) then
        return
    elseif IsStringEmpty(descriptor) then
        return
    elseif IsStringEmpty(description) then
        return
    end

    if Entities[label] == nil then
        Entities[label] = {}
    end
    Entities[label][descriptor] = description
end

function SetLocation(label, location)
    if Entities[label] == nil then
        return
    end

    if location ~= nil then
        Entities[label]["location"] = location
    elseif CurrentCity ~= "" then
        Entities[label]["location"] = CurrentCity
    elseif CurrentRegion ~= "" then
        Entities[label]["location"] = CurrentRegion
    elseif CurrentContinent ~= "" then
        Entities[label]["location"] = CurrentContinent
    end
end

function AutomatedChapters()
    AddNPCsToPlaces()
    ComplementRefs()
    CreateNPCs()
    CreateGeography()
end
