local organisationTypes = { "organisation", "ship" }

function IsOrganisation(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], organisationTypes)
end
