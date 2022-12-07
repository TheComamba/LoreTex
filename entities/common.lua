function IsEntity(inp)
    if type(inp) ~= "table" then
        return false
    else
        return GetProtectedStringField(inp, "label") ~= ""
    end
end

function GetAllLabels(list)
    local out = {}
    if IsEntity(list) then
        list = { list }
    end
    for key, entry in pairs(list) do
        if IsEntity(entry) then
            local label = GetProtectedStringField(entry, "label")
            if label ~= "" then
                UniqueAppend(out, label)
            end
            UniqueAppend(out, GetAllLabels(GetProtectedTableField(entry, "subEntities")))
        end
    end
    return out
end
