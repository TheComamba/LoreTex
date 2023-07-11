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
