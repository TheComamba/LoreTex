AllEntities = {}
CurrentEntity = nil
local labelToEntity = {}

StateResetters[#StateResetters + 1] = function()
    AllEntities = {}
    CurrentEntity = nil
    labelToEntity = {}
end

function GetEntitiesIf(condition, list)
    local out = {}
    if list == nil or type(list) ~= "table" then
        LogError { "Called with ", DebugPrint(list) }
        return out
    end
    for key, entity in pairs(list) do
        if condition(entity) then
            out[#out + 1] = entity
        end
    end
    return out
end

function GetEntitiesOfCategory(category, list)
    local out = {}
    if list == nil then
        list = AllEntities
    end
    for key, entity in pairs(list) do
        if GetProtectedStringField(entity, "category") == category then
            out[#out + 1] = entity
        end
    end
    return out
end

local function newEntity(label)
    local entity = {}
    SetProtectedField(entity, "label", label)
    AllEntities[#AllEntities + 1] = entity
    labelToEntity[label] = entity
    return entity
end

function GetMutableEntityFromAll(label)
    if label == "" then
        LogError("Called with empty label!")
        return {}
    end
    local entity = labelToEntity[label]
    if entity == nil then
        newEntity(label)
        entity = labelToEntity[label]
    end
    return entity
end

function GetEntity(label)
    local entity = labelToEntity[label]
    if entity == nil and not IsIn(label, UnfoundRefs) then
        LogError("Entity with label \"" .. label .. "\" not found.")
        Append(UnfoundRefs, label)
        entity = {}
    end
    return ReadonlyTable(entity)
end
