function SetDescriptor(label, descriptor, description, subdescriptor)
    if IsEmpty(label) then
        return
    elseif IsEmpty(descriptor) then
        return
    elseif IsEmpty(description) then
        return
    end

    if Entities[label] == nil then
        Entities[label] = {}
    end
    if IsEmpty(subdescriptor) then
        Entities[label][descriptor] = description
    else
        if Entities[label][descriptor] == nil then
            Entities[label][descriptor] = {}
        end
        if type(Entities[label][descriptor]) ~= "table" then
            local error = "Trying to add subdescriptor \""
            error = error .. subdescriptor
            error = error .. "\" to descriptor \""
            error = error .. descriptor
            error = error .. "\" of entity \""
            error = error .. label
            error = error .. "\", which already contains a string content."
            LogError(error)
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
    PrintEntityChapter("Charaktere", GetEntitiesIf(IsChar), CharacterTypes)
    PrintEntityChapter("Organisationen", GetEntitiesIf(IsOrganisation), OrganisationTypes)
    PrintEntityChapter("Sprachen", GetEntitiesIf(IsLanguage), LanguageTypes)
    PrintEntityChapter("Gegenstände", GetEntitiesIf(IsItem), ItemTypes)
    PrintErrors()
end

function ResetCurrentLabels()
    CurrentLabel = ""
    CurrentContinent = ""
    CurrentRegion = ""
    CurrentCity = ""
end
