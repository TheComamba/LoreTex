function IsEntity(inp)
    if type(inp) ~= "table" then
        return false
    end
    for key, val in pairs(inp) do
        if IsProtectedDescriptor(key) then
            return true
        end
    end
    return false
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
