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
        SetProtectedField(newEntity, "label", label)
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
    return IsIn(GetProtectedStringField(entity, "label"), RevealedLabels)
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

function IsEntity(inp)
    if type(inp) ~= "table" then
        return false
    end
    for key, val in pairs(inp) do
        if IsProtectedDescriptor(key) then
            return true
        end
    end
    return false
end

local function splitContentatSubparagraph(content)
    local contentSplit = {}
    local lastpos = 0
    while lastpos >= 0 do
        local nextpos = string.find(content, [[\subparagraph]], lastpos + 1)
        local part = ""
        if nextpos == nil then
            part = string.sub(content, lastpos)
            nextpos = -1
        else
            part = string.sub(content, lastpos, nextpos - 1)
        end
        Append(contentSplit, part)
        lastpos = nextpos
    end
    return contentSplit
end

local function mergePartsWithoutLabels(splitContent)
    local out = { splitContent[1] }
    for i = 2, #splitContent do
        local part = splitContent[i]
        local labels = ScanForCmd(part, "label")
        if #labels == 0 then
            out[#out] = out[#out] .. part
        else
            Append(out, part)
        end
    end
    return out
end

local function contentToEntityRaw(arg)
    if not IsArgOk("contentToEntityRaw", arg, { "mainEntity", "name", }, { "content" }) then
        return {}
    end

    local labels = ScanForCmd(arg.content, "label")
    local newEntity = {}
    if #labels > 0 then
        newEntity = GetMutableEntityFromAll(labels[1])
        for i = 2, #labels do
            LogError("Label \"" .. labels[i] .. "\" will be ignored.")
        end
    end
    SetProtectedField(newEntity, "name", arg.name)
    SetProtectedField(newEntity, "content", arg.content)
    MakePartOf { subEntity = newEntity, mainEntity = arg.mainEntity }
    return newEntity
end

function LabeledContentToEntity(arg)
    if not IsArgOk("LabeledContentToEntity", arg, { "mainEntity", "name", "content" }) then
        return ""
    end

    local contentSplit = splitContentatSubparagraph(arg.content)
    contentSplit = mergePartsWithoutLabels(contentSplit)
    local newEntity = contentToEntityRaw { mainEntity = arg.mainEntity,
        name = arg.name,
        content = contentSplit[1] }
    for i = 2, #contentSplit do
        local part = contentSplit[i]
        local name = ScanForCmd(part, "subparagraph")[1]
        contentToEntityRaw { mainEntity = newEntity, name = name, content = part }
    end
    return newEntity
end

function LabelToName(label)
    if IsEmpty(label) then
        return ""
    end
    StartBenchmarking("LabelToName")
    local name = ""
    local entity = labelToEntity[label]
    if not IsEmpty(entity) then
        name = GetProtectedStringField(entity, "name")
    elseif not IsIn(label, UnfoundRefs) then
        LogError("Label \"" .. label .. "\" not found.")
        Append(UnfoundRefs, label)
        name = label:upper()
    end
    StopBenchmarking("LabelToName")
    return name
end

function GetAllLabels(list)
    local out = {}
    if IsEntity(list) then
        list = { list }
    end
    for key, entry in pairs(list) do
        if IsEntity(entry) then
            local label = GetProtectedStringField(entry, "label")
            if not IsEmpty(label) then
                UniqueAppend(out, label)
            end
            UniqueAppend(out, GetAllLabels(GetProtectedTableField(entry, "subEntities")))
        end
    end
    return out
end
