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

function GetMainLabel(entity)
    if type(entity) ~= "table" then
        LogError("Called with " .. DebugPrint(entity))
        return "CALLED WITH WRONG TYPE"
    end
    local labels = GetProtectedTableField(entity, "labels")
    if IsEmpty(labels) then
        return "MAIN LABEL NOT FOUND"
    else
        return labels[1]
    end
end

function IsPrimary(entity)
    local labels = GetProtectedTableField(entity, "labels")
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
        if GetProtectedStringField(entity, "type") == type then
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
    local entity = labelToEntity[label]
    if IsEmpty(entity) and not IsIn(label, UnfoundRefs) then
        LogError("Entity with label \"" .. label .. "\" not found.")
        Append(UnfoundRefs, label)
        entity = {}
    end
    while GetProtectedNullableField(entity, "partOf") ~= nil do
        entity = GetProtectedNullableField(entity, "partOf")
    end
    entity = ReadonlyTable(entity)
    StopBenchmarking("GetEntity")
    return entity
end

function IsEntitySecret(entity)
    if entity == nil then
        return false
    end
    local isSecret = GetProtectedNullableField(entity, "isSecret")
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
    return IsAnyElemIn(GetProtectedTableField(entity, "labels"), RevealedLabels)
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
    local aliasEntity = GetMutableEntityFromAll(alias)
    if not IsEmpty(aliasEntity) then --TODO: This is currently always true
        mergeEntities(mainEntity, aliasEntity)
        RegisterEntityLabel(alias, mainEntity)
        local mt = {}
        mt.__index = mainEntity
        mt.__newindex = mainEntity
        mt.__pairs = function() return pairs(mainEntity) end
        mt.__ipairs = function() return ipairs(mainEntity) end
        setmetatable(aliasEntity, mt)
    end
end

function IsEntity(inp)
    if type(inp) ~= "table" then
        return false
    end
    local labels = GetProtectedNullableField(inp, "labels")
    return not IsEmpty(labels)
end

function LabelToNameFromContent(arg)
    if not IsArgOk("LabelToNameFromContent", arg, { "label", "descriptor", "content" }) then
        return ""
    end
    local foundLabels = ScanForCmd(arg.content, "label")
    local labelIndex = nil
    for ind, someLabel in pairs(foundLabels) do
        if someLabel == arg.label then
            labelIndex = ind
            break
        end
    end
    if labelIndex == nil then
        return ""
    end
    local subparagraphs = ScanForCmd(arg.content, "subparagraph")
    if #foundLabels == #subparagraphs then
        return subparagraphs[labelIndex]
    else
        return arg.descriptor
    end
end

function LabelToName(label)
    local entity = GetEntity(label)
    if label == GetMainLabel(entity) then
        return GetShortname(entity)
    else
        for paragraph, content in pairs(entity) do
            local name = LabelToNameFromContent { label = label, descriptor = paragraph, content = content }
            if not IsEmpty(name) then
                return name
            end
        end
    end
    if not IsIn(label, UnfoundRefs) then
        LogError("Label \"" .. label .. "\" not found.")
        Append(UnfoundRefs, label)
    end
    return label:upper()
end
