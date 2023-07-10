local allTypes = {}

StateResetters[#StateResetters + 1] = function()
    allTypes = {}
end

function IsType(type, entity)
    local entityType = GetProtectedStringField(entity, "type")
    return type == entityType
end

function IsTypeKnown(queriedType)
    return IsIn(queriedType, allTypes)
end

function AddType(type)
    UniqueAppend(allTypes, type)
end

function GetSortedTypes()
    Sort(allTypes, "compareAlphanumerical")
    return allTypes
end

--TODO delete this api function
TexApi.addType = AddType
