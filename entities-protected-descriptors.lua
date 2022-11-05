local protectedDescriptors = {}

local function addProtectedDescriptor(descriptor)
    Append(protectedDescriptors, descriptor)
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

function GetProtectedField(entity, key)
    if not IsIn(key, protectedDescriptors) then
        LogError("key \"" .. key .. "\"not found in protectedDescriptors.")
        return nil
    end
    return entity[key]
end

function SetProtectedField(entity, key, value)
    if not IsIn(key, protectedDescriptors) then
        LogError("key \"" .. key .. "\"not found in protectedDescriptors.")
        return nil
    end
    entity[key] = value
end

function AddToProtectedField(entity, key, value)
    if not IsIn(key, protectedDescriptors) then
        LogError("key \"" .. key .. "\"not found in protectedDescriptors.")
        return nil
    end
    if entity[key] == nil then
        entity[key] = {}
    end
    entity[key][#entity[key] + 1] = value
end

function IsProtectedDescriptor(descriptor)
    return IsIn(descriptor, protectedDescriptors)
end
