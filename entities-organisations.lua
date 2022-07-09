OrganisationTypes = { "organisation", "ship" }
OrganisationTypeNames = { "Organisationen", "Schiffe" }

function IsOrganisation(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], OrganisationTypes)
end
