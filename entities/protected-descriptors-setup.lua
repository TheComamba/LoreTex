local protectedDescriptors = {}

local function addProtectedDescriptor(descriptor)
    protectedDescriptors[descriptor] = "_" .. descriptor
end

addProtectedDescriptor("ageExponent")
addProtectedDescriptor("ageFactor")
addProtectedDescriptor("ageMixing")
addProtectedDescriptor("birthof")
addProtectedDescriptor("born")
addProtectedDescriptor("children")
addProtectedDescriptor("concerns")
addProtectedDescriptor("content")
addProtectedDescriptor("counter")
addProtectedDescriptor("day")
addProtectedDescriptor("deathof")
addProtectedDescriptor("died")
addProtectedDescriptor("historyItems")
addProtectedDescriptor("isConcernsOthers")
addProtectedDescriptor("isSecret")
addProtectedDescriptor("label")
addProtectedDescriptor("location")
addProtectedDescriptor("mentions")
addProtectedDescriptor("monthsAndFirstDays")
addProtectedDescriptor("name")
addProtectedDescriptor("originator")
addProtectedDescriptor("parents")
addProtectedDescriptor("partOf")
addProtectedDescriptor("shortname")
addProtectedDescriptor("species")
addProtectedDescriptor("subEntities")
addProtectedDescriptor("type")
addProtectedDescriptor("year")
addProtectedDescriptor("yearAbbreviation")
addProtectedDescriptor("yearFormat")
addProtectedDescriptor("yearOffset")

function GetProtectedDescriptor(key)
    local descriptor = protectedDescriptors[key]
    if descriptor == nil then
        LogError("Key \"" .. key .. "\" does not name a protected descriptor.")
        return ""
    end
    return descriptor
end
