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

local function scanStringForRefs(str)
    if str == nil then
        return
    end
    local refs = {}
    local keyword1 = [[\myref {]]
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

function ScanForRefs(content)
    if content == nil or type(content) == "boolean" or type(content) == "number" then
        return {}
    elseif type(content) == "string" then
        return scanStringForRefs(content)
    elseif type(content) == "table" then
        local out = {}
        for key, elem in pairs(content) do
            Append(out, ScanForRefs(elem))
        end
        return out
    else
        LogError("Tried to scan content of type " .. type(content) .. "!")
        return {}
    end
end

function ScanContentForSecondaryRefs(content)
    for key, ref in pairs(ScanForRefs(content)) do
        if not IsIn(ref, PrimaryRefs) then
            AddRef(ref, SecondaryRefs)
        end
    end
end

function ReplaceMyrefWithNameref(content)
    if type(content) == "string" then
        return string.gsub(content, [[\myref]], [[\nameref]])
    elseif type(content) == "table" then
        for key, elem in pairs(content) do
            content[key] = ReplaceMyrefWithNameref(elem)
        end
        return content
    elseif type(content) == "boolean" or type(content) == "number" then
        return content
    else
        LogError("Tried to replace myref in an object of type " .. type(content) .. "!")
        return content
    end
end

function AddAllEntitiesToPrimaryRefs()
    for label, elem in pairs(Entities) do
        AddRef(label, PrimaryRefs)
    end
end
