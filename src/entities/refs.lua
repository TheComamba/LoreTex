PrimaryRefs = {}
MentionedRefs = {}
UnfoundRefs = {}
PrimaryRefWhenMentionedCategories = {}
local refTypes = { "reference", "nameref", "itref", "ref", "silentref" }

function ResetRefs()
    PrimaryRefs = {}
    MentionedRefs = {}
    UnfoundRefs = {}
    PrimaryRefWhenMentionedCategories = {}
end

StateResetters[#StateResetters + 1] = ResetRefs

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

function ScanStringForCmd(str, cmd)
    local args = {}
    local cmdStr = [[\]] .. cmd
    local openStr = [[{]]
    local closeStr = [[}]]
    local posCmd = string.find(str, cmdStr)
    local posClose = 0
    while posCmd ~= nil do
        local posOpenTmp = string.find(str, openStr, posCmd)
        if not posOpenTmp then
            LogError("No opening bracket found for command \"" .. cmd .. "\".")
            break
        end
        local posOpen = posOpenTmp

        local posCloseTmp = string.find(str, closeStr, math.max(posOpen, posClose + 1))
        if not posCloseTmp then
            LogError("No closing bracket found for command \"" .. cmd .. "\".")
            break
        end
        posClose = posCloseTmp

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

local function continueRcursion(key, subcontent)
    if IsProtectedDescriptor(key) then
        return false
    elseif IsEntity(subcontent) and not IsSubEntity(subcontent) then
        return false
    else
        return true
    end
end

function ScanForCmd(content, cmd)
    local out = {}
    if type(content) == "string" then
        out = ScanStringForCmd(content, cmd)
    elseif type(content) == "table" then
        for key, subcontent in pairs(content) do
            if continueRcursion(key, subcontent) then
                local commands = ScanForCmd(subcontent, cmd)
                Append(out, commands)
            end
        end
    end
    return out
end

local function scanContentForMentionedRefs(content)
    local mentionedRefsHere = {}
    for key1, refType in pairs(refTypes) do
        local refs = ScanForCmd(content, refType)
        UniqueAppend(mentionedRefsHere, refs)
    end
    return mentionedRefsHere
end

function GetMentionedEntities(content)
    local refs = scanContentForMentionedRefs(content)
    local mentions = {}
    for _, ref in pairs(refs) do
        local entity = GetMutableEntityFromAll(ref)
        if entity ~= nil then
            UniqueAppend(mentions, entity)
        end
    end
    return mentions
end

local function makeAllEntitiesPrimary()
    for key, entity in pairs(AllEntities) do
        UniqueAppend(PrimaryRefs, GetAllLabels(entity))
    end
end

TexApi.makeAllEntitiesPrimary = makeAllEntitiesPrimary

local function makeCategoryPrimaryWhenMentioned(category)
    UniqueAppend(PrimaryRefWhenMentionedCategories, category)
end

TexApi.makeCategoryPrimaryWhenMentioned = makeCategoryPrimaryWhenMentioned

local function makeEntityAndChildrenPrimary(label)
    UniqueAppend(PrimaryRefs, label)
    local entity = GetEntity(label)
    if entity == nil then
        LogError("Entity with label \"" .. label .. "\" not found.")
        return
    end
    for key, child in pairs(GetProtectedTableReferenceField(entity, "children")) do
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

TexApi.makeAllEntitiesOfCategoryPrimary = function(category)
    makePrimaryIf(Bind(HasCategory, category))
end

TexApi.makeEntityPrimary = function(label)
    UniqueAppend(PrimaryRefs, label)
end

TexApi.mention = function(label)
    UniqueAppend(MentionedRefs, label)
end
