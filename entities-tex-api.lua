function SetDescriptor(label, descriptor, description, subdescriptor)
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
    if subdescriptor == nil then
        Entities[label][descriptor] = description
    else
        if Entities[label][descriptor] == nil then
            Entities[label][descriptor] = {}
        end
        Entities[label][descriptor][subdescriptor] = description
    end
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
    AddAutomatedDescriptors()
    ComplementRefs()
    CreateGeography()
    PrintEntityChapter("Charaktere", GetEntitiesIf(IsChar))
    PrintEntityChapter("Organisationen", GetEntitiesIf(IsOrganisation))
    PrintEntityChapter("Sprachen", GetEntitiesIf(IsLanguage))
    PrintEntityChapter("Gegenstände", GetEntitiesIf(IsItem))
end

function ResetCurrentLabels()
    CurrentLabel = ""
    CurrentContinent = ""
    CurrentRegion = ""
    CurrentCity = ""
end
