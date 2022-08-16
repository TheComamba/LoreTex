PrimaryRefs = {}
SecondaryRefs = {}
UnfoundRefs = {}
IsAppendix = false

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
    local str = TexCmd("nameref", label)
    str = str .. " (Ref. "
    str = str .. TexCmd("speech", label)
    str = str .. ")"
    return str
end

function ListAllRefs()
    tex.print(TexCmd("paragraph", "primaryRefs"))
    tex.print(ListAll(PrimaryRefs, NamerefString))
    tex.print(TexCmd("paragraph", "secondaryRefs"))
    tex.print(ListAll(SecondaryRefs, NamerefString))
end

local function scanStringFor(str, cmd)
    if IsEmpty(cmd) then
        LogError("Called with empty command!")
        return {}
    end
    local refs = {}
    local keyword1 = [[\]] .. cmd .. [[ {]] --TODO: I do not like the space...
    local keyword2 = [[}]]
    local pos1 = string.find(str, keyword1)
    while pos1 ~= nil do
        local pos2 = string.find(str, keyword2, pos1)
        local ref = string.sub(str, pos1 + string.len(keyword1), pos2 - 1)
        if not IsIn(ref, refs) then
            refs[#refs + 1] = ref
        end
        pos1 = string.find(str, keyword1, pos2)
    end
    return refs
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
    for key, ref in pairs(ScanForCmd(content, "myref")) do
        if not IsIn(ref, PrimaryRefs) then
            AddRef(ref, SecondaryRefs)
        end
    end
end

function AddAllEntitiesToPrimaryRefs()
    for key, entity in pairs(Entities) do
        AddRef(GetLabels(entity), PrimaryRefs)
    end
end
