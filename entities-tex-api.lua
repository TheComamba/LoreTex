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
        Entities[label]["label"] = label
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

function SetSecret(label)
    SetDescriptor(label, "isSecret", true)
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

function AddAssociation(label, association, role)
    if Entities[label] ~= nil then
        if Entities[label]["association"] == nil then
            Entities[label]["association"] = {}
        end
        Entities[label]["association"][#Entities[label]["association"]+1] = {association, role}
    end
end

function DeclarePC(label)
    PCs[#PCs + 1] = label
    AddRef(label, PrimaryRefs)
end

function NewEntity(label, type, shortname, name)
    CurrentLabel = label
    SetDescriptor(CurrentLabel, "type", type)
    SetDescriptor(CurrentLabel, "shortname", shortname)
    SetDescriptor(CurrentLabel, "name", name)
end

function NewCharacter(label, shortname, name)
    if IsIn(label, PCs) then
        NewEntity(label, "pc", shortname, name)
    else
        NewEntity(label, "npc", shortname, name)
    end
end

function AutomatedChapters()
    DeleteUnborn()
    MarkDead()
    MarkSecret()
    AddAutomatedDescriptors()
    ComplementRefs()
    local output = CreateGeography()
    Append(output, PrintEntityChapter("Landmarken", GetEntitiesIf(IsLandmark), LandmarkTypes))
    Append(output, PrintEntityChapter("Charaktere", GetEntitiesIf(IsChar), CharacterTypes))
    Append(output, PrintEntityChapter("Zusammenschlüsse", GetEntitiesIf(IsAssociation), AssociationTypes))
    Append(output, PrintEntityChapter("Sprachen", GetEntitiesIf(IsLanguage), LanguageTypes))
    Append(output, PrintEntityChapter("Gegenstände", GetEntitiesIf(IsItem), ItemTypes))
    Append(output, PrintErrors())
    tex.print(table.concat(output))
end
