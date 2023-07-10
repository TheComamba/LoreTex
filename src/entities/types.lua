AllTypes = {}

StateResetters[#StateResetters + 1] = function()
    AllTypes = {}
end

function IsType(type, entity)
    local entityType = GetProtectedStringField(entity, "type")
    return type == entityType
end

function IsTypeKnown(queriedType)
    return IsIn(queriedType, AllTypes)
end

function AddType(type)
    UniqueAppend(AllTypes, type)
end

--TODO delete this api function
TexApi.addType = AddType
