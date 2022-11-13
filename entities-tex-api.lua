TexApi = {}

function SetDescriptor(arg)
    if not IsArgOk("SetDescriptor", arg, { "entity", "descriptor", "description" }, { "subdescriptor" }) then
        return
    end

    StartBenchmarking("SetDescriptor")
    Replace([[\reference]], [[\nameref]], arg.description)

    if IsEmpty(arg.subdescriptor) then
        arg.entity[arg.descriptor] = arg.description
    else
        if arg.entity[arg.descriptor] == nil then
            arg.entity[arg.descriptor] = {}
        end
        if type(arg.entity[arg.descriptor]) ~= "table" then
            local error = {}
            Append(error, "Trying to add subdescriptor \"")
            Append(error, arg.subdescriptor)
            Append(error, "\" to descriptor \"")
            Append(error, arg.descriptor)
            Append(error, "\" of an entity which already contains a string content: ")
            Append(error, DebugPrint(arg.entity))
            LogError(table.concat(error))
        end
        arg.entity[arg.descriptor][arg.subdescriptor] = arg.description
    end
    local labels = GetLabels(arg.entity)
    local additionalLabels = ScanForCmd(arg.description, "label")
    UniqueAppend(labels, additionalLabels)
    RegisterEntityLabels(additionalLabels, arg.entity)
    AddDescriptorsFromNotYetFound(arg.entity)
    StopBenchmarking("SetDescriptor")
end

TexApi.setDescriptor = function(arg)
    arg.entity = CurrentEntity()
    SetDescriptor(arg)
end

local function declarePC(label)
    PCs[#PCs + 1] = label
    AddRef(label, PrimaryRefs)
end

TexApi.declarePC = declarePC

local function reveal(label)
    AddRef(label, RevealedLabels)
    AddRef(label, PrimaryRefs)
end

TexApi.reveal = reveal

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

local function newEntity(arg)
    if not IsArgOk("newEntity", arg, { "type", "label", "name" }, { "shortname" }) then
        return
    end
    if not IsTypeKnown(arg.type) then
        LogError("Trying to create entity with unkown type \"" .. arg.type .. "\"")
        return
    end
    StartBenchmarking("NewEntity")
    local entity = {}
    SetProtectedField(entity, "type", arg.type)
    SetProtectedField(entity, "labels", { arg.label })
    SetProtectedField(entity, "shortname", arg.shortname)
    SetProtectedField(entity, "name", arg.name)
    local defaultLocation = GetScopedVariable("DefaultLocation")
    if not IsEmpty(defaultLocation) then
        SetLocation(entity, defaultLocation)
    end
    RegisterEntityLabels(arg.label, entity)
    AddDescriptorsFromNotYetFound(entity)
    AllEntities[#AllEntities + 1] = entity
    StopBenchmarking("NewEntity")
end

TexApi.newEntity = newEntity

local function newCharacter(arg)
    if IsIn(arg.label, PCs) then
        arg.type = "pcs"
        newEntity(arg)
    else
        arg.type = "npcs"
        newEntity(arg)
    end
end

TexApi.newCharacter = newCharacter

local function automatedChapters()
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

TexApi.automatedChapters = automatedChapters
