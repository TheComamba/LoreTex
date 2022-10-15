PrimaryRefs = {}
SecondaryRefs = {}
UnfoundRefs = {}
PrimaryRefTypes = {}
IsAppendix = false
RefTypes = { "reference", "nameref", "itref", "ref" }

local function addSingleRef(label, refs)
    if label ~= nil and not IsIn(label, refs) then
        refs[#refs + 1] = label
    end
end

function AddRef(labels, refs)
    if type(labels) == "string" then
        addSingleRef(labels, refs)
    elseif type(labels) == "table" then
        for key, label in pairs(labels) do
            AddRef(label, refs)
        end
    end
end

function IsContainsPrimary(list)
    for key, label in pairs(list) do
        if IsIn(label, PrimaryRefs) then
            return true
        end
    end
    return false
end

function AddRefPrimaryOrSecondary(label)
    if not IsAppendix then
        AddRef(label, PrimaryRefs)
    else
        AddRef(label, SecondaryRefs)
    end
end

function NamerefString(label)
    return TexCmd("nameref", label)
end

local function namerefDebugString(label)
    local out = {}
    Append(out, TexCmd("nameref", label))
    Append(out, [[\\ (Ref. ]])
    Append(out, TexCmd("speech", label))
    Append(out, ")")
    return table.concat(out)
end

function ListAllRefs()
    tex.print(TexCmd("paragraph", "primaryRefs"))
    tex.print(ListAll(PrimaryRefs, namerefDebugString))
    tex.print(TexCmd("paragraph", "secondaryRefs"))
    tex.print(ListAll(SecondaryRefs, namerefDebugString))
end

local function scanStringFor(str, cmd)
    if type(str) ~= "string" then
        LogError("Called with " .. DebugPrint(str))
        return {}
    elseif IsEmpty(cmd) or type(cmd) ~= "string" then
        LogError("Called with " .. DebugPrint(cmd))
        return {}
    end
    local args = {}
    local cmdStr = [[\]] .. cmd
    local openStr = [[{]]
    local closeStr = [[}]]
    local posCmd = string.find(str, cmdStr)
    while posCmd ~= nil do
        local posOpen = string.find(str, openStr, posCmd)
        local posClose = string.find(str, closeStr, posOpen)

        local between = string.sub(str, posCmd + string.len(cmdStr), posOpen - 1)
        local arg = string.sub(str, posOpen + string.len(openStr), posClose - 1)
        if IsEmpty(between) then
            if not IsIn(arg, args) then
                args[#args + 1] = arg
            end
        end

        posCmd = string.find(str, cmdStr, posClose)
    end
    return args
end

function ScanForCmd(content, cmd)
    if content == nil or type(content) == "boolean" or type(content) == "number" then
        return {}
    elseif type(content) == "string" then
        return scanStringFor(content, cmd)
    elseif type(content) == "table" then
        local out = {}
        for key, elem in pairs(content) do
            Append(out, ScanForCmd(elem, cmd))
        end
        return out
    else
        LogError("Tried to scan content of type " .. type(content) .. "!")
        return {}
    end
end

function ScanContentForSecondaryRefs(content)
    for key1, refType in pairs(RefTypes) do
        for key2, ref in pairs(ScanForCmd(content, refType)) do
            if not IsIn(ref, PrimaryRefs) then
                AddRef(ref, SecondaryRefs)
            end
        end
    end
end

function AddAllEntitiesToPrimaryRefs()
    for key, entity in pairs(AllEntities) do
        AddRef(GetLabels(entity), PrimaryRefs)
    end
end

function MakeTypePrimary(type)
    UniqueAppend(PrimaryRefTypes, type)
end