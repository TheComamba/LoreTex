ItemTypes = { "item" }

function IsItem(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], ItemTypes)
end
