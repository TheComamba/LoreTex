function SetDescriptor(entity, descriptor, description, subdescriptor)
    if IsEmpty(entity) then
        LogError("Called with empty entity. Descriptor is " .. DebugPrint(descriptor))
        return
    elseif IsEmpty(descriptor) then
        LogError("Called with empty descriptor for entity with label " .. GetMainLabel(entity) .. "\"")
        return
    elseif IsEmpty(description) then
        return
    elseif IsProtectedDescriptor(descriptor) then
    -- elseif IsIn(descriptor, protectedDescriptors) then
        LogError("Called with protected descriptor \"" ..
            descriptor .. "\" for entity with label \"" .. GetMainLabel(entity) .. "\"")
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
    RegisterEntityLabels(additionalLabels, entity)
    AddDescriptorsFromNotYetFound(entity)
    StopBenchmarking("SetDescriptor")
end

function SetSecret(entity)
    entity["isSecret"] = true
end

function Reveal(label)
    AddRef(label, RevealedLabels)
    AddRef(label, PrimaryRefs)
end

function AddParent(entity, parentLabel, relationship)
    if entity ~= nil then
        if entity["parents"] == nil then
            entity["parents"] = {}
        end
        entity["parents"][#entity["parents"] + 1] = { parentLabel, relationship }
    end
    local parent = GetMutableEntityFromAll(parentLabel)
    if parent["children"] == nil then
        parent["children"] = {}
    end
    UniqueAppend(parent["children"], GetMainLabel(entity))
end

function DeclarePC(label)
    PCs[#PCs + 1] = label
    AddRef(label, PrimaryRefs)
end

function SetAgeFactor(entity, factor)
    entity["ageFactor"] = factor
end

function SetAgeExponent(entity, exponent)
    entity["ageExponent"] = exponent
end

function SetAgeModifierMixing(entity, species1, species2)
    entity["ageMixing"] = { species1, species2 }
end

function SetLocation(entity, location)
    entity["location"] = location
    AddParent(entity, location)
end

function SetSpecies(entity, species)
    entity["species"] = species
end

function SetGender(entity, gender)
    entity["gender"] = gender
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

function NewEntity(type, label, shortname, name)
    if IsEmpty(type) then
        LogError("Entity " .. label .. " has no type!")
        return
    elseif not IsTypeKnown(type) then
        LogError("Trying to create entity with unkown type \"" .. type .. "\"")
        return
    elseif IsEmpty(label) then
        LogError("Called with no label!")
        return
    elseif IsEmpty(name) then
        LogError("Entity " .. name .. " has no name!")
        return
    end
    StartBenchmarking("NewEntity")
    local entity = {}
    entity["type"] = type
    entity["labels"] = { label }
    entity["shortname"] = shortname
    entity["name"] = name
    local defaultLocation = GetScopedVariable("DefaultLocation")
    if not IsEmpty(defaultLocation) then
        SetLocation(entity, defaultLocation)
    end
    RegisterEntityLabels(label, entity)
    AddDescriptorsFromNotYetFound(entity)
    AllEntities[#AllEntities + 1] = entity
    StopBenchmarking("NewEntity")
end

function NewCharacter(label, shortname, name)
    if IsIn(label, PCs) then
        NewEntity("pcs", label, shortname, name)
    else
        NewEntity("npcs", label, shortname, name)
    end
end

function AutomatedChapters()
    if not IsEmpty(NotYetFoundEntities) then
        ComplainAboutNotYetFoundEntities()
    end
    StartBenchmarking("AutomatedChapters")
    local processedEntities, mentionedRefs = ProcessEntities(AllEntities)
    local output = {}
    for key, metatype in pairs(SortedMetatypes()) do
        Append(output, PrintEntityChapter(processedEntities, metatype))
    end
    Append(output, PrintOnlyMentionedChapter(mentionedRefs))
    if HasError() then
        Append(output, TexCmd("chapter", "Logging Messages"))
        Append(output, TexCmd("RpgTex"))
        Append(output, " encountered errors. Call PrintRpgTexErrors to show them.")
    end
    StopBenchmarking("AutomatedChapters")
    return output
end
