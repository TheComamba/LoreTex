SpeciesTypes = { "species"}
SpeciesTypeNames = { "Spezies" }

function IsSpecies(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], SpeciesTypes)
end
