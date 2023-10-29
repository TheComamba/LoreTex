Debug = {}

Debug.makeFirstEntitiesPrimary = function(number)
    for key, entity in pairs(AllEntities) do
        if key > number then
            break
        end
        UniqueAppend(PrimaryRefs, GetAllLabels(entity))
    end
end

local function namerefDebugString(label)
    local out = {}
    Append(out, TexCmd("nameref", label))
    Append(out, [[\\ (Ref. ]])
    Append(out, TexCmd("speech", label))
    Append(out, ")")
    return table.concat(out)
end

local function listAllRefs()
    tex.print(TexCmd("paragraph", "PrimaryRefs"))
    tex.print(ListAll(PrimaryRefs, namerefDebugString))
    tex.print(TexCmd("paragraph", "MentionedRefs"))
    tex.print(ListAll(MentionedRefs, namerefDebugString))
end

Debug.listAllRefs = listAllRefs

Debug.printDescriptorsImmediately = function()
    local setDescriptorOriginal = TexApi.setDescriptor
    ---@diagnostic disable-next-line: duplicate-set-field
    TexApi.setDescriptor = function(arg)
        tex.print(arg.description)
        tex.print(arg.descriptor)
        setDescriptorOriginal(arg)
    end
end

Debug.debugAutomatedChapters = function()
    local out = TexApi.automatedChapters()
    tex.print(TexCmd("begin", "verbatim"))
    for i, line in pairs(out) do
        tex.print(line)
    end
    tex.print(TexCmd("end", "verbatim"))
end

Debug.storeHistoryOriginator = function()
    Debug.addProtectedDescriptor("originator")
    local addHistoryOriginal = TexApi.addHistory
    ---@diagnostic disable-next-line: duplicate-set-field
    TexApi.addHistory = function(arg)
        addHistoryOriginal(arg)
        local item = AllHistoryItems[#AllHistoryItems]
        SetProtectedField(item, "originator", CurrentEntity)
    end
end

Debug.warnIfHistoryConcernsOtherCategory = function(originatorCategory, targetCategory)
    local messages = {}
    for _, item in pairs(AllHistoryItems) do
        local originator = GetProtectedNullableField(item, "originator")
        if originator == nil then
            tex.print([[History item has no originator! The \verb"\storeHistoryOriginator" command needs to be called before \verb"\addHistory".]])
            return
        end

        if GetProtectedStringField(originator, "category") == originatorCategory then
            local concerns = GetHistoryConcerns(item)
            for _, entity in pairs(concerns) do
                local concernCategory = GetProtectedStringField(entity, "category")
                if concernCategory == targetCategory then
                    local originatorLabel = GetProtectedStringField(originator, "label")
                    local label = GetProtectedStringField(entity, "label")
                    local content = GetProtectedStringField(item, "content")
                    content = Replace([[\nameref]], [[]], content)
                    content = Replace([[\reference]], [[]], content)
                    content = Replace([[\silentref]], [[]], content)
                    local errorMessage = originatorLabel ..
                        " has history concerning " .. label .. [[:\\]] .. content
                    Append(messages, errorMessage)
                end
            end
        end
    end
    if #messages > 0 then
        tex.print(TexCmd("paragraph", "History items concerning other category"))
        tex.print(ListAll(messages))
    end
end
