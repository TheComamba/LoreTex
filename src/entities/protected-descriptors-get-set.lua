local protectedDescriptors = {}
local isInheritableDescriptor = {}

local function addProtectedDescriptor(descriptor)
    protectedDescriptors[descriptor] = "_" .. descriptor
end

local function addInheritableDescriptor(descriptor)
    isInheritableDescriptor[descriptor] = true
    addProtectedDescriptor(descriptor)
end

StateResetters[#StateResetters + 1] = function()
    protectedDescriptors = {}
    isInheritableDescriptor = {}
    addInheritableDescriptor("ageExponent")
    addInheritableDescriptor("ageFactor")
    addInheritableDescriptor("ageMixing")
    addProtectedDescriptor("birthof")
    addInheritableDescriptor("born")
    addInheritableDescriptor("category")
    addProtectedDescriptor("children")
    addProtectedDescriptor("concerns")
    addProtectedDescriptor("content")
    addInheritableDescriptor("day")
    addProtectedDescriptor("deathof")
    addInheritableDescriptor("died")
    addInheritableDescriptor("height")
    addProtectedDescriptor("historyItems")
    addProtectedDescriptor("isConcernsOthers")
    addInheritableDescriptor("isSecret")
    addProtectedDescriptor("label")
    addInheritableDescriptor("location")
    addProtectedDescriptor("mentions")
    addProtectedDescriptor("monthsAndFirstDays")
    addProtectedDescriptor("name")
    addInheritableDescriptor("originator")
    addInheritableDescriptor("parents")
    addProtectedDescriptor("partOf")
    addProtectedDescriptor("shortname")
    addInheritableDescriptor("species")
    addInheritableDescriptor("year")
    addInheritableDescriptor("yearAbbreviation")
    addInheritableDescriptor("yearOffset")
end

function GetProtectedDescriptor(key)
    if IsProtectedDescriptor(key) then
        return key
    end
    local descriptor = protectedDescriptors[key]
    if descriptor == nil then
        LogError("Key \"" .. key .. "\" does not name a protected descriptor.")
        return ""
    end
    return descriptor
end

function IsProtectedDescriptor(descriptor)
    return string ~= "" and string.sub(descriptor, 1, 1) == "_"
end

local function getProtectedField(entity, key, inherit)
    if type(entity) ~= "table" then
        LogError("Expected table, got " .. type(entity) .. "!")
        return nil
    end

    if inherit == nil then
        inherit = true
    end
    local descriptor = GetProtectedDescriptor(key)
    local field = entity[descriptor]
    if field ~= nil or not inherit then
        return field
    end
    if isInheritableDescriptor[key] then
        local super = getProtectedField(entity, "partOf")
        if super ~= nil then
            return getProtectedField(super, key, inherit)
        end
    end
    return nil
end

function GetProtectedNullableField(entity, key, inherit)
    return getProtectedField(entity, key, inherit)
end

function GetProtectedStringField(entity, key, inherit)
    local out = getProtectedField(entity, key, inherit)
    if out == nil then
        return ""
    elseif type(out) ~= "string" then
        LogError("Expected string, got " .. type(out) .. " for key \"" .. key .. "\"!")
        return ""
    else
        return out
    end
end

function GetProtectedTableReferenceField(entity, key, inherit)
    local out = getProtectedField(entity, key, inherit)
    if out == nil then
        return {}
    elseif type(out) ~= "table" then
        LogError("Expected table, got " .. type(out) .. " for key \"" .. key .. "\"!")
        return {}
    else
        return out
    end
end

function GetProtectedTableCopyField(entity, key, inherit)
    return DeepCopy(GetProtectedTableReferenceField(entity, key, inherit))
end

function SetProtectedField(entity, key, value)
    if type(entity) ~= "table" then
        LogError("Expected table, got " .. type(entity) .. "!")
        return
    end

    local descriptor = GetProtectedDescriptor(key)
    entity[descriptor] = value
end

function AddToProtectedField(entity, key, value)
    local descriptor = GetProtectedDescriptor(key)
    if entity[descriptor] == nil then
        entity[descriptor] = {}
    elseif type(entity[descriptor]) ~= "table" then
        LogError("Expected table, got " .. type(entity[descriptor]) .. " for key \"" .. key .. "\"!")
        return
    end
    entity[descriptor][#entity[descriptor] + 1] = value
end
