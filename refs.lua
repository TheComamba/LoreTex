PrimaryRefs = {}
SecondaryRefs = {}
UnfoundRefs = {}
function AddRef(label, refs)
    if label ~= nil and not IsIn(label, refs) then
        refs[#refs + 1] = label
    end
end

IsAppendix = false
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

function ScanForRefs(str)
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

function ScanForSecondaryRefs(str)
    for key, ref in pairs(ScanForRefs(str)) do
        if not IsIn(ref, PrimaryRefs) then
            AddRef(ref, SecondaryRefs)
        end
    end
end

function ScanContentForSecondaryRefs(list)
    local primaryEntries = GetPrimaryRefEntities(list)
    for label, entry in pairs(primaryEntries) do
        for key, content in pairs(entry) do
            if type(content) == "string" then
                ScanForSecondaryRefs(content)
            elseif type(content) == "table" then
                for key2, subcontent in pairs(content) do
                    if type(subcontent) == "string" then
                        ScanForSecondaryRefs(subcontent)
                    end
                end
            end
        end
    end
end

function AddAllRefsToPrimary()
    for label, elem in pairs(Entities) do
        AddRef(label, PrimaryRefs)
    end
end
