ClassTypes = { "class", "subclass" }
ClassTypeNames = { "Klassen", "Subklassen" }

function IsClass(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], ClassTypes)
end
