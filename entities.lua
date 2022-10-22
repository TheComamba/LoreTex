AllEntities = {}
NotYetFoundEntities = {}
local labelToEntity = {}
IsShowSecrets = false
ProtectedDescriptors = { "name", "shortname", "type", "isSecret", "labels", "parents", "children" }
RevealedLabels = {}

function ResetEntities()
    AllEntities = {}
    NotYetFoundEntities = {}
    labelToEntity = {}
    IsShowSecrets = false
    RevealedLabels = {}
end

ResetEntities()

function ComplainAboutNotYetFoundEntities()
    for label, entity in pairs(NotYetFoundEntities) do
        LogError("Entity with label \"" .. label .. "\" was mentioned, but not created.")
    end
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

function RegisterEntityLabels(labels, entity)
    if type(labels) ~= "table" then
        labels = { labels }
    end
    for key, label in pairs(labels) do
        labelToEntity[label] = entity
    end
end

function GetMutableEntityFromAll(label)
    local entity = labelToEntity[label]
    if entity == nil then
        if NotYetFoundEntities[label] == nil then
            NotYetFoundEntities[label] = {}
        end
        entity = NotYetFoundEntities[label]
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

function AddDescriptorsFromNotYetFound(entity)
    for key, label in pairs(GetLabels(entity)) do
        local preliminaryEntity = NotYetFoundEntities[label]
        if preliminaryEntity ~= nil then
            for field, value in pairs(preliminaryEntity) do
                if entity[field] == nil then
                    entity[field] = value
                elseif type(entity[field]) == "table" and type(value) == "table" then
                    for key, subvalue in pairs(value) do
                        if type(key) == "number" then
                            entity[field][#entity[field] + 1] = subvalue
                        else
                            if entity[field][key] == nil then
                                entity[field][key] = subvalue
                            else
                                LogError("Tried to add already existing field " .. DebugPrint(key))
                            end
                        end
                    end
                else
                    LogError("Tried to add already existing field " .. DebugPrint(field))
                end
            end
            NotYetFoundEntities[label] = nil
        end
    end
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
    if type(entity1) == "table" then
        return StrCmp(GetShortname(entity1), GetShortname(entity2))
    elseif type(entity1) == "string" then
        return StrCmp(LabelToName(entity1), LabelToName(entity2))
    end
end
