AllEntities = {}
CurrentEntity = nil
local labelToEntity = {}
IsShowSecrets = false
RevealedLabels = {}

function ResetEntities()
    AllEntities = {}
    CurrentEntity = nil
    labelToEntity = {}
    IsShowSecrets = false
    RevealedLabels = {}
end

ResetEntities()

function GetLabels(entity)
    local labels = GetProtectedField(entity, "labels")
    if labels == nil then
        return {}
    else
        return labels
    end
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
        if GetProtectedField(entity, "type") == type then
            out[#out + 1] = entity
        end
    end
    StopBenchmarking("GetEntitiesOfType")
    return out
end

function RegisterEntityLabel(label, entity)
    labelToEntity[label] = entity
end

function GetMutableEntityFromAll(label)
    local entity = labelToEntity[label]
    if entity == nil then
        local newEntity = {}
        AddToProtectedField(newEntity, "labels", label)
        AllEntities[#AllEntities + 1] = newEntity
        RegisterEntityLabel(label, newEntity)
        entity = labelToEntity[label]
    end
    return entity
end

function GetEntity(label)
    StartBenchmarking("GetEntity")
    local entity = ReadonlyTable(labelToEntity[label])
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
    local isSecret = GetProtectedField(entity, "isSecret")
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

local function joinEntitiesError(arg)
    local mainLabel = GetMainLabel(arg.main)
    local alias = GetMainLabel(arg.aliasEntity)
    local errorMessage = {}
    Append(errorMessage, "Collision while joining entities \"")
    Append(errorMessage, mainLabel)
    Append(errorMessage, "\" and \"")
    Append(errorMessage, alias)
    Append(errorMessage, "\": Key \"")
    Append(errorMessage, arg.key)
    Append(errorMessage, "\" defined with different ")
    Append(errorMessage, arg.errorType)
    Append(errorMessage, ".")
    LogError(errorMessage)
end

local function mergeEntities(mainEntity, aliasEntity)
    for key, val in pairs(aliasEntity) do
        if IsEmpty(mainEntity[key]) then
            mainEntity[key] = val
        else
            if type(val) ~= type(mainEntity[key]) then
                joinEntitiesError { main = mainEntity, aliasEntity = aliasEntity, key = key, errorType = "types" }
                return
            elseif type(val) ~= "table" then
                if val ~= mainEntity[key] then
                    joinEntitiesError { main = mainEntity, aliasEntity = aliasEntity, key = key, errorType = "values" }
                    return
                end
            else
                JoinTables(val, mainEntity[key])
            end
        end
    end
end

function MergeWithAlias(mainEntity, alias)
    local aliasEntity = labelToEntity[alias]
    if not IsEmpty(aliasEntity) then
        mergeEntities(mainEntity, aliasEntity)
    end
    local mainLabel = GetMainLabel(mainEntity)
    labelToEntity[alias] = labelToEntity[mainLabel]
end
