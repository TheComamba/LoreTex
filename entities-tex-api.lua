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

function DeclarePC(label)
    PCs[#PCs + 1] = label
end

function NewEntity(label, type, shortname, name)
    CurrentLabel = label
    SetDescriptor(CurrentLabel, "type", type)
    SetDescriptor(CurrentLabel, "shortname", shortname)
    SetDescriptor(CurrentLabel, "name", name)
end

function NewNPC(label, shortname, name)
    if IsIn(label, PCs) then
        NewEntity(label, "pc", shortname, name)
        LogError("Creating PC " .. label)
    else
        NewEntity(label, "npc", shortname, name)
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
