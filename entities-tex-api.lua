function SetDescriptor(entity, descriptor, description, subdescriptor)
    if IsEmpty(descriptor) then
        return
    elseif IsEmpty(description) then
        return
    end

    if IsEmpty(subdescriptor) then
        entity[descriptor] = description
    else
        if entity[descriptor] == nil then
            entity[descriptor] = {}
        end
        if type(entity[descriptor]) ~= "table" then
            local error = "Trying to add subdescriptor \""
            error = error .. subdescriptor
            error = error .. "\" to descriptor \""
            error = error .. descriptor
            error = error .. "\" of an entity which already contains a string content: "
            error = error .. DebugPrint(entity)
            LogError(error)
        end
        entity[descriptor][subdescriptor] = description
    end
end

function SetSecret(entity)
    SetDescriptor(entity, "isSecret", true)
end

function SetLocation(entity, location)
    if location ~= nil then
        entity["location"] = location
    elseif CurrentCity ~= "" then
        entity["location"] = CurrentCity
    elseif CurrentRegion ~= "" then
        entity["location"] = CurrentRegion
    elseif CurrentContinent ~= "" then
        entity["location"] = CurrentContinent
    end
end

function AddAssociation(entity, association, role)
    if entity ~= nil then
        if entity["association"] == nil then
            entity["association"] = {}
        end
        entity["association"][#entity["association"] + 1] = { association, role }
    end
end

function DeclarePC(label)
    PCs[#PCs + 1] = label
    AddRef(label, PrimaryRefs)
end

function NewEntity(label, type, shortname, name)
    if IsEmpty(label) then
        LogError("Called with no label!")
        return
    elseif IsEmpty(type) then
        LogError("Entity " .. label .. " has no type!")
        return
    elseif IsEmpty(name) then
        LogError("Entity " .. name .. " has no name!")
        return
    end
    local entity = {}
    SetDescriptor(entity, "labels", {label})
    SetDescriptor(entity, "type", type)
    SetDescriptor(entity, "shortname", shortname)
    SetDescriptor(entity, "name", name)
    Entities[#Entities + 1] = entity
end

function NewCharacter(label, shortname, name)
    if IsIn(label, PCs) then
        NewEntity(label, "pc", shortname, name)
    else
        NewEntity(label, "npc", shortname, name)
    end
end

function AutomatedChapters()
    ScanEntitiesForLabels()
    AddAutomatedDescriptors()
    ComplementRefs()
    MarkDead()
    MarkSecret()
    local output = CreateGeography()
    Append(output, PrintEntityChapter("Landmarken", GetEntitiesIf(IsLandmark), LandmarkTypes))
    Append(output, PrintEntityChapter("Charaktere", GetEntitiesIf(IsChar), CharacterTypes))
    Append(output, PrintEntityChapter("Zusammenschlüsse", GetEntitiesIf(IsAssociation), AssociationTypes))
    Append(output, PrintEntityChapter("Sprachen", GetEntitiesIf(IsLanguage), LanguageTypes))
    Append(output, PrintEntityChapter("Gegenstände", GetEntitiesIf(IsItem), ItemTypes))
    Append(output, PrintErrors())
    tex.print(table.concat(output))
end
