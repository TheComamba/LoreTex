AssociationTypes = { "organisation", "ship" }
AssociationTypeNames = { "Organisationen", "Schiffe" }

function IsAssociation(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], AssociationTypes)
end
