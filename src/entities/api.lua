local function declarePC(label)
    PCs[#PCs + 1] = label
    UniqueAppend(PrimaryRefs, label)
end

TexApi.declarePC = declarePC

local function newEntity(arg)
    if not IsArgOk("newEntity", arg, { "category", "label", "name" }, { "shortname" }) then
        return
    end
    CurrentEntity = GetMutableEntityFromAll(arg.label)
    if not IsEmpty(GetProtectedStringField(CurrentEntity, "name")) then
        LogError("An Entity with label " .. arg.label .. " already exists. It was not created a second time.")
        return
    end
    SetProtectedField(CurrentEntity, "category", arg.category)
    AddCategory(arg.category)
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
        arg.category = "PCs"
        newEntity(arg)
    else
        arg.category = "NPCs"
        newEntity(arg)
    end
end

TexApi.newCharacter = newCharacter

local function automatedChapters()
    local processOut = ProcessedEntities()
    local output = {}
    for _, category in pairs(GetSortedCategories()) do
        Append(output, PrintEntityChapter(processOut, category))
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
