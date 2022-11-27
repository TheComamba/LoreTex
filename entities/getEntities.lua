AllEntities = {}
CurrentEntity = nil
local labelToEntity = {}

StateResetters[#StateResetters + 1] = function()
    AllEntities = {}
    CurrentEntity = nil
    labelToEntity = {}
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
    local out = {}
    if list == nil then
        list = AllEntities
    end
    for key, entity in pairs(list) do
        if GetProtectedStringField(entity, "type") == type then
            out[#out + 1] = entity
        end
    end
    return out
end

function GetMutableEntityFromAll(label)
    if label == "" then
        LogError("Called with empty label!")
        return {}
    end
    local entity = labelToEntity[label]
    if entity == nil then
        local newEntity = {}
        SetProtectedField(newEntity, "label", label)
        AllEntities[#AllEntities + 1] = newEntity
        labelToEntity[label] = newEntity
        entity = labelToEntity[label]
    end
    return entity
end

function GetEntityRaw(label)
    local entity = labelToEntity[label]
    if IsEmpty(entity) and not IsIn(label, UnfoundRefs) then
        LogError("Entity with label \"" .. label .. "\" not found.")
        Append(UnfoundRefs, label)
        entity = {}
    end
    return ReadonlyTable(entity)
end

function GetEntity(label)
    local entity = GetEntityRaw(label)
    while GetProtectedNullableField(entity, "partOf") ~= nil do
        entity = GetProtectedNullableField(entity, "partOf")
    end
    return ReadonlyTable(entity)
end
