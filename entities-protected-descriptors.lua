local protectedDescriptors = {}

local function addProtectedDescriptor(descriptor)
    protectedDescriptors[descriptor] = "_" .. descriptor .. "_"
end

addProtectedDescriptor("ageExponent")
addProtectedDescriptor("ageFactor")
addProtectedDescriptor("ageMixing")
addProtectedDescriptor("born")
addProtectedDescriptor("children")
addProtectedDescriptor("died")
addProtectedDescriptor("gender")
addProtectedDescriptor("historyItems")
addProtectedDescriptor("isSecret")
addProtectedDescriptor("labels")
addProtectedDescriptor("location")
addProtectedDescriptor("monthsAndFirstDays")
addProtectedDescriptor("name")
addProtectedDescriptor("parents")
addProtectedDescriptor("species")
addProtectedDescriptor("shortname")
addProtectedDescriptor("type")
addProtectedDescriptor("yearAbbreviation")

function IsProtectedDescriptor(descriptor)
    for key, protectedDescriptor in pairs(protectedDescriptors) do
        if protectedDescriptor == descriptor then
            return true
        end
    end
    return false
end

function GetProtectedField(entity, key)
    local descriptor = protectedDescriptors[key]
    if descriptor == nil then
        LogError("Key \"" .. key .. "\" does not name a protected descriptor.")
        return nil
    end
    return entity[descriptor]
end

function SetProtectedField(entity, key, value)
    local descriptor = protectedDescriptors[key]
    if descriptor == nil then
        LogError("Key \"" .. key .. "\" does not name a protected descriptor.")
        return nil
    end
    entity[descriptor] = value
end

function AddToProtectedField(entity, key, value)
    local descriptor = protectedDescriptors[key]
    if descriptor == nil then
        LogError("Key \"" .. key .. "\" does not name a protected descriptor.")
        return nil
    end
    if entity[descriptor] == nil then
        entity[descriptor] = {}
    end
    entity[descriptor][#entity[descriptor] + 1] = value
end
