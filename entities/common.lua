function IsEntity(inp)
    if type(inp) ~= "table" then
        return false
    else
        return GetProtectedStringField(inp, "label") ~= ""
    end
end

function GetAllLabels(entity)
    local out = {}
    UniqueAppend(out, GetProtectedStringField(entity, "label"))
    for key, val in pairs(entity) do
        if not IsProtectedDescriptor(key) and IsEntity(val) then
            UniqueAppend(out, GetAllLabels(val))
        end
    end
    return out
end
