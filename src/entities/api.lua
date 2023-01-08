local function declarePC(label)
    PCs[#PCs + 1] = label
    UniqueAppend(PrimaryRefs, label)
end

TexApi.declarePC = declarePC

local function newEntity(arg)
    if not IsArgOk("newEntity", arg, { "type", "label", "name" }, { "shortname" }) then
        return
    end
    if not IsTypeKnown(arg.type) then
        LogError("Trying to create entity with unkown type \"" .. arg.type .. "\"")
        return
    end
    CurrentEntity = GetMutableEntityFromAll(arg.label)
    SetProtectedField(CurrentEntity, "type", arg.type)
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
        arg.type = "pcs"
        newEntity(arg)
    else
        arg.type = "npcs"
        newEntity(arg)
    end
end

TexApi.newCharacter = newCharacter

local function automatedChapters()
    local processOut = ProcessedEntities()
    local output = {}
    for key, metatype in pairs(SortedMetatypes()) do
        Append(output, PrintEntityChapter(processOut, metatype))
    end
    Append(output, PrintOnlyMentionedChapter(processOut.mentioned))
    if HasError() then
        Append(output, TexCmd("chapter", "Logging Messages"))
        Append(output, TexCmd("RpgTex"))
        Append(output, " encountered errors. Call PrintRpgTexErrors to show them.")
    end
    if IsBenchmarkingActivated ~= nil and IsBenchmarkingActivated() then
        return {}
    else
        return output
    end
end

TexApi.automatedChapters = automatedChapters
