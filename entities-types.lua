function TypeToNameMap()
    local allTypes = {}
    local allTypeNames = {}
    Append(allTypes, AssociationTypes)
    Append(allTypeNames, AssociationTypeNames)
    Append(allTypes, CharacterTypes)
    Append(allTypeNames, CharacterTypeNames)
    Append(allTypes, PlaceTypes)
    Append(allTypeNames, PlaceTypeNames)
    Append(allTypes, ItemTypes)
    Append(allTypeNames, ItemTypeNames)
    Append(allTypes, LanguageTypes)
    Append(allTypeNames, LanguageTypeNames)
    Append(allTypes, LandmarkTypes)
    Append(allTypeNames, LandmarkTypeNames)
    Append(allTypes, SpeciesTypes)
    Append(allTypeNames, SpeciesTypeNames)
    Append(allTypes, SpellTypes)
    Append(allTypeNames, SpellTypeNames)
    Append(allTypes, ClassTypes)
    Append(allTypeNames, ClassTypeNames)
    Append(allTypes, OtherEntityTypes)
    Append(allTypeNames, OtherEntityTypeNames)
    local out = {}
    for i, key in pairs(allTypes) do
        out[key] = allTypeNames[i]
    end
    return out
end

function IsType(types, entity)
    if IsEmpty(entity) then
        LogError("Called with empty entity!")
        return false
    end
    return IsIn(entity["type"], types)
end
