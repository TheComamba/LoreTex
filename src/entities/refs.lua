PrimaryRefs = {}
MentionedRefs = {}
UnfoundRefs = {}
PrimaryRefWhenMentionedTypes = {}
local refTypes = { "reference", "nameref", "itref", "ref" }

StateResetters[#StateResetters + 1] = function()
    PrimaryRefs = {}
    MentionedRefs = {}
    UnfoundRefs = {}
    PrimaryRefWhenMentionedTypes = {}
end

function IsContainsPrimary(list)
    for key, label in pairs(list) do
        if IsIn(label, PrimaryRefs) then
            return true
        end
    end
    return false
end

function NamerefString(label)
    return TexCmd("nameref", label)
end

local function namerefDebugString(label)
    local out = {}
    Append(out, TexCmd("nameref", label))
    Append(out, [[\\ (Ref. ]])
    Append(out, TexCmd("speech", label))
    Append(out, ")")
    return table.concat(out)
end

local function listAllRefs()
    tex.print(TexCmd("paragraph", "PrimaryRefs"))
    tex.print(ListAll(PrimaryRefs, namerefDebugString))
    tex.print(TexCmd("paragraph", "MentionedRefs"))
    tex.print(ListAll(MentionedRefs, namerefDebugString))
end

TexApi.listAllRefs = listAllRefs

function ScanStringForCmd(str, cmd)
    local args = {}
    local cmdStr = [[\]] .. cmd
    local openStr = [[{]]
    local closeStr = [[}]]
    local posCmd = string.find(str, cmdStr)
    local posClose = 0
    while posCmd ~= nil do
        local posOpen = string.find(str, openStr, posCmd)
        posClose = string.find(str, closeStr, math.max(posOpen, posClose + 1))

        local between = string.sub(str, posCmd + string.len(cmdStr), posOpen - 1)
        local arg = string.sub(str, posOpen + string.len(openStr), posClose - 1)

        local _, openCount = string.gsub(arg, openStr, openStr)
        local _, closeCount = string.gsub(arg, closeStr, closeStr)
        if openCount == closeCount then
            if IsEmpty(between) then
                if not IsIn(arg, args) then
                    args[#args + 1] = arg
                end
            end
            posCmd = string.find(str, cmdStr, posClose)
        end
    end
    return args
end

function ScanForCmd(content, cmd)
    local out = {}
    if type(content) == "string" then
        out = ScanStringForCmd(content, cmd)
    elseif type(content) == "table" then
        for key, elem in pairs(content) do
            if not IsProtectedDescriptor(key) then
                local commands = ScanForCmd(elem, cmd)
                Append(out, commands)
            end
        end
    end
    return out
end

function ScanContentForMentionedRefs(content)
    local mentionedRefsHere = {}
    for key1, refType in pairs(refTypes) do
        local refs = ScanForCmd(content, refType)
        UniqueAppend(mentionedRefsHere, refs)
    end
    return mentionedRefsHere
end

local function makeAllEntitiesPrimary()
    for key, entity in pairs(AllEntities) do
        UniqueAppend(PrimaryRefs, GetAllLabels(entity))
    end
end

TexApi.makeAllEntitiesPrimary = makeAllEntitiesPrimary

local function makeTypePrimaryWhenMentioned(type)
    UniqueAppend(PrimaryRefWhenMentionedTypes, type)
end

TexApi.makeTypePrimaryWhenMentioned = makeTypePrimaryWhenMentioned

local function makeEntityAndChildrenPrimary(label)
    UniqueAppend(PrimaryRefs, label)
    local entity = GetEntity(label)
    if entity == nil then
        LogError("Entity with label \"" .. label .. "\" not found.")
        return
    end
    for key, child in pairs(GetProtectedTableField(entity, "children")) do
        UniqueAppend(PrimaryRefs, GetProtectedStringField(child, "label"))
    end
end

local function makePrimaryIf(condition)
    for key, entity in pairs(AllEntities) do
        if (condition(entity)) then
            local label = GetProtectedStringField(entity, "label")
            UniqueAppend(PrimaryRefs, label)
        end
    end
end

TexApi.makeEntityAndChildrenPrimary = makeEntityAndChildrenPrimary

TexApi.makeAllEntitiesOfTypePrimary = function(type)
    makePrimaryIf(Bind(IsType, type))
end

TexApi.makeEntityPrimary = function(label)
    UniqueAppend(PrimaryRefs, label)
end

TexApi.mention = function(label)
    UniqueAppend(MentionedRefs, label)
end

TexApi.makeFirstEntitiesPrimary = function(number)
    for key, entity in pairs(AllEntities) do
        if key > number then
            break
        end
        UniqueAppend(PrimaryRefs, GetAllLabels(entity))
    end
end
