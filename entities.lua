AllEntities = {}
local labelToEntity = {}
IsShowSecrets = false
ProtectedDescriptors = { "name", "shortname", "type", "isSecret", "labels", "parents", "children" }
OtherEntityTypes = { "other" }
OtherEntityTypeNames = { "Andere" }
RevealedLabels = {}

function IsOtherEntity(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], OtherEntityTypes)
end

function CurrentEntity()
    return AllEntities[#AllEntities]
end

function GetLabels(entity)
    local labels = entity["labels"]
    if labels == nil then
        return {}
    elseif type(labels) == "string" then
        return { labels }
    else
        return labels
    end
end

function GetNumberField(entity, key, default)
    local out = entity[key]
    if out == nil then
        out = default
    elseif tonumber(out) == nil then
        LogError("Could not convert to number: " .. DebugPrint(out))
        out = default
    else
        out = tonumber(out)
    end
    return out
end

function GetMainLabel(entity)
    if type(entity) ~= "table" then
        LogError("Called with " .. DebugPrint(entity))
        return "CALLED WITH WRONG TYPE"
    end
    local labels = GetLabels(entity)
    if IsEmpty(labels) then
        return "MAIN LABEL NOT FOUND"
    else
        return labels[1]
    end
end

function IsPrimary(entity)
    local labels = GetLabels(entity)
    return IsAnyElemIn(labels, PrimaryRefs)
end

function GetEntitiesIf(condition, list)
    StartBenchmarking("GetEntitiesIf")
    local out = {}
    if list == nil or type(list) ~= "table" then
        LogError("Called with " .. DebugPrint(list))
        StopBenchmarking("GetEntitiesIf")
        return out
    end
    for key, entity in pairs(list) do
        if condition(entity) then
            out[#out + 1] = entity
        end
    end
    StopBenchmarking("GetEntitiesIf")
    return out
end

function GetEntitiesOfType(type, list)
    StartBenchmarking("GetEntitiesOfType")
    local out = {}
    if list == nil then
        list = AllEntities
    end
    for key, entity in pairs(list) do
        if entity["type"] == type then
            out[#out + 1] = entity
        end
    end
    StopBenchmarking("GetEntitiesOfType")
    return out
end

function RegisterEntityLabel(labels, entity)
    if type(labels) ~= "table" then
        labels = { labels }
    end
    for key, label in pairs(labels) do
        labelToEntity[label] = entity
    end
end

function GetMutableEntity(label, entityList)
    if entityList == AllEntities then
        LogError("Trying to get mutable reference to member of AllEntities.")
        return {}
    end
    for key, entity in pairs(entityList) do
        if IsIn(label, GetLabels(entity)) then
            return entity
        end
    end
    return {}
end

function GetMutableEntityFromAll(label)
    local entity = labelToEntity[label]
    if IsEmpty(entity) then
        entity = {}
    end
    return entity
end

function GetEntity(label)
    StartBenchmarking("GetEntity")
    local entity = ReadonlyTable(GetMutableEntityFromAll(label))
    if IsEmpty(entity) and not IsIn(label, UnfoundRefs) then
        LogError("Entity with label \"" .. label .. "\" not found.")
        AddRef(label, UnfoundRefs)
        entity = {}
    end
    StopBenchmarking("GetEntity")
    return entity
end

function IsEntitySecret(entity)
    if entity == nil then
        return false
    end
    local isSecret = entity["isSecret"]
    if isSecret == nil then
        return false
    end
    if type(isSecret) ~= "boolean" then
        LogError("isSecret property of " .. DebugPrint(entity) .. " should be boolean, but is " .. type(isSecret) .. ".")
        return false
    end
    return isSecret
end

function IsRevealed(entity)
    return IsAnyElemIn(GetLabels(entity), RevealedLabels)
end

function IsEntityShown(entity)
    if IsEmpty(entity) then
        return false
    elseif not IsBorn(entity) and not IsShowFuture then
        return false
    elseif IsEntitySecret(entity) then
        if IsRevealed(entity) or IsShowSecrets then
            return true
        else
            return false
        end
    else
        return true
    end
end

function CompareByName(entity1, entity2)
    local name1 = GetShortname(entity1)
    local name2 = GetShortname(entity2)
    return StrCmp(name1, name2)
end
