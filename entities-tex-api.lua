function SetDescriptor(entity, descriptor, description, subdescriptor)
    if IsEmpty(descriptor) then
        return
    elseif IsEmpty(description) then
        return
    end

    StartBenchmarking("SetDescriptor")
    Replace([[\reference]], [[\nameref]], description)

    if IsEmpty(subdescriptor) then
        entity[descriptor] = description
    else
        if entity[descriptor] == nil then
            entity[descriptor] = {}
        end
        if type(entity[descriptor]) ~= "table" then
            local error = {}
            Append(error, "Trying to add subdescriptor \"")
            Append(error, subdescriptor)
            Append(error, "\" to descriptor \"")
            Append(error, descriptor)
            Append(error, "\" of an entity which already contains a string content: ")
            Append(error, DebugPrint(entity))
            LogError(table.concat(error))
        end
        entity[descriptor][subdescriptor] = description
    end
    local labels = GetLabels(entity)
    local additionalLabels = ScanForCmd(description, "label")
    UniqueAppend(labels, additionalLabels)
    StopBenchmarking("SetDescriptor")
end

function SetSecret(entity)
    SetDescriptor(entity, "isSecret", true)
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

function SetAgeModifierMixing(entity, species1, species2)
    SetDescriptor(entity, "ageMixing", { species1, species2 })
end

function MakePrimaryIf(condition)
    StartBenchmarking("MakePrimaryIf")
    for key, entity in pairs(AllEntities) do
        if (condition(entity)) then
            local label = GetMainLabel(entity)
            AddRef(label, PrimaryRefs)
        end
    end
    StopBenchmarking("MakePrimaryIf")
end

function NewEntity(label, type, shortname, name)
    StartBenchmarking("NewEntity")
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
    SetDescriptor(entity, "labels", { label })
    SetDescriptor(entity, "type", type)
    SetDescriptor(entity, "shortname", shortname)
    SetDescriptor(entity, "name", name)
    if not IsEmpty(DefaultLocation) then
        SetDescriptor(entity, "location", DefaultLocation)
    end
    AddSpecialFieldsToPreviouslyUnfoundEntity(entity)
    AllEntities[#AllEntities + 1] = entity
    StopBenchmarking("NewEntity")
end

function NewCharacter(label, shortname, name)
    if IsIn(label, PCs) then
        NewEntity(label, "pc", shortname, name)
    else
        NewEntity(label, "npc", shortname, name)
    end
end

function AutomatedChapters()
    StartBenchmarking("AutomatedChapters")
    local processedEntities = ProcessEntities(AllEntities)
    local output = {}
    Append(output, PrintEntityChapter(processedEntities, "Orte", PlaceTypes))
    Append(output, PrintEntityChapter(processedEntities, "Landmarken", LandmarkTypes))
    Append(output, PrintEntityChapter(processedEntities, "Charaktere", CharacterTypes))
    Append(output, PrintEntityChapter(processedEntities, "Zusammenschlüsse", AssociationTypes))
    Append(output, PrintEntityChapter(processedEntities, "Spezies", SpeciesTypes))
    Append(output, PrintEntityChapter(processedEntities, "Sprachen", LanguageTypes))
    Append(output, PrintEntityChapter(processedEntities, "Klassen", ClassTypes))
    Append(output, PrintEntityChapter(processedEntities, "Zauber", SpellTypes))
    Append(output, PrintEntityChapter(processedEntities, "Gegenstände", ItemTypes))
    Append(output, PrintEntityChapter(processedEntities, "Andere", OtherEntityTypes))
    Append(output, PrintOnlyMentionedChapter())
    if HasError() then
        Append(output, TexCmd("chapter", "Logging Messages"))
        Append(output, TexCmd("RpgTex"))
        Append(output, [[ encountered errors. Call \\PrintRpgTexErrors to show them.]])
    end
    StopBenchmarking("AutomatedChapters")
    return output
end
