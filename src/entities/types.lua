AllTypes = {}

StateResetters[#StateResetters + 1] = function()
    AllTypes = {}
end

function IsType(type, entity)
    local entityType = GetProtectedStringField(entity, "type")
    if entityType == nil then
        return false
    else
        local types = AllTypes[type]
        if types == nil then
            return entityType == type
        else
            return IsIn(entityType, types)
        end
    end
end

function IsTypeKnown(queriedType)
    for key1, types in pairs(AllTypes) do
        for key2, type in pairs(types) do
            if type == queriedType then
                return true
            end
        end
    end
    return false
end

function GetMetatype(typename)
    for metatype, types in pairs(AllTypes) do
        if IsIn(typename, types) then
            return metatype
        end
    end
    LogError("Type \"" .. typename .. "\" not found!")
    return ""
end

function SortedMetatypes()
    local metatypes = {}
    for key, types in pairs(AllTypes) do
        Append(metatypes, key)
    end
    Sort(metatypes, "compareTranslation")
    return metatypes
end

local function addType(arg)
    if not IsArgOk("addType", arg, { "metatype", "type" }, {}) then
        return
    end
    if AllTypes[arg.metatype] == nil then
        AllTypes[arg.metatype] = {}
    end
    Append(AllTypes[arg.metatype], arg.type)
end

TexApi.addType = addType
