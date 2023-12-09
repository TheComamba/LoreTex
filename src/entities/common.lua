function IsEntity(inp)
    if type(inp) ~= "table" then
        return false
    else
        return GetProtectedStringField(inp, "label") ~= "" or GetProtectedNullableField(inp, "timestamp") ~= nil
    end
end

function GetAllLabels(entity)
    local out = {}
    local label = GetProtectedStringField(entity, "label")
    if not IsLabelGenerated(label) then
        UniqueAppend(out, label)
    end
    for key, val in pairs(entity) do
        if not IsProtectedDescriptor(key) and IsEntity(val) then
            UniqueAppend(out, GetAllLabels(val))
        end
    end
    return out
end
