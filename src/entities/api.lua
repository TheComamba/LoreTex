local function declarePC(label)
    PCs[#PCs + 1] = label
    UniqueAppend(PrimaryRefs, label)
end

TexApi.declarePC = declarePC

local function newEntity(arg)
    if not IsArgOk("newEntity", arg, { "type", "label", "name" }, { "shortname" }) then
        return
    end
    CurrentEntity = GetMutableEntityFromAll(arg.label)
    SetProtectedField(CurrentEntity, "type", arg.type)
    AddType(arg.type)
    SetProtectedField(CurrentEntity, "shortname", arg.shortname)
    SetProtectedField(CurrentEntity, "name", arg.name)
    local defaultLocation = GetScopedVariable("DefaultLocation")
    if defaultLocation ~= nil then
        SetLocation(CurrentEntity, defaultLocation)
    end
end

TexApi.newEntity = newEntity

local function newCharacter(arg)
    if IsIn(arg.label, PCs) then
        arg.type = "PCs"
        newEntity(arg)
    else
        arg.type = "NPCs"
        newEntity(arg)
    end
end

TexApi.newCharacter = newCharacter

local function automatedChapters()
    local processOut = ProcessedEntities()
    local output = {}
    Sort(AllTypes)
    for _, type in pairs(AllTypes) do
        Append(output, PrintEntityChapter(processOut, type))
    end
    Append(output, PrintOnlyMentionedChapter(processOut.mentioned))
    if HasError() then
        Append(output, TexCmd("chapter", "Logging Messages"))
        Append(output, TexCmd("LoreTex"))
        Append(output, [[ encountered errors. Call \verb'\printLoreTexErrors' to show them.]])
    end
    if IsBenchmarkingActivated ~= nil and IsBenchmarkingActivated() then
        return {}
    else
        return output
    end
end

TexApi.automatedChapters = automatedChapters
