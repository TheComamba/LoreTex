local isShowFuture = false
local isShowSecrets = false
local revealedLabels = {}

StateResetters[#StateResetters + 1] = function()
    isShowFuture = false
    isShowSecrets = false
    revealedLabels = {}
end

TexApi.showSecrets = function(isShow)
    if isShow == nil then
        isShow = true
    end
    isShowSecrets = isShow
end

TexApi.showFuture = function(isShow)
    if isShow == nil then
        isShow = true
    end
    isShowFuture = isShow
end

local function reveal(label)
    UniqueAppend(revealedLabels, label)
    UniqueAppend(PrimaryRefs, label)
end

TexApi.reveal = reveal

function AreSecretsShown()
    return isShowSecrets
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
        LogError("isSecret property of entity \"" ..
            GetProtectedStringField(entity, "label") .. "\" should be boolean, but is " .. type(isSecret) .. ".")
        return false
    end
    return isSecret
end

function IsRevealed(entity)
    return IsIn(GetProtectedStringField(entity, "label"), revealedLabels)
end

function IsEntityUnrevealed(entity)
    if AreSecretsShown() then
        return false
    end
    return IsEntitySecret(entity) and (not IsRevealed(entity))
end

function IsEntityShown(entity)
    if not IsBorn(entity) and not isShowFuture then
        return false
    elseif IsEntitySecret(entity) then
        if IsRevealed(entity) or AreSecretsShown() then
            return true
        else
            return false
        end
    else
        return true
    end
end

function IsLocationUnrevealed(entity)
    local location = GetProtectedNullableField(entity, "location")
    return IsEntityUnrevealed(location)
end

local function concernsAndMentions(historyItem)
    local out = GetHistoryConcerns(historyItem)
    Append(out, GetHistoryMentions(historyItem))
    return out
end

local function isConcernsOrMentionsUnrevealed(historyItem)
    for key, entity in pairs(concernsAndMentions(historyItem)) do
        if IsEntitySecret(entity) and not IsRevealed(entity) then
            return true
        end
    end
    return false
end

function IsConcernsOrMentionsSecret(historyItem)
    for key, entity in pairs(concernsAndMentions(historyItem)) do
        if IsEntitySecret(entity) then
            return true
        end
    end
    return false
end

local function isAllConcnernsAndMentionsShown(historyItem)
    for key, entity in pairs(concernsAndMentions(historyItem)) do
        if not IsEntityShown(entity) then
            return false
        end
    end
    return true
end

function IsHistoryShown(historyItem)
    if IsEmpty(historyItem) then
        return false
    elseif not isAllConcnernsAndMentionsShown(historyItem) then
        return false
    elseif not isShowFuture and IsFutureEvent(historyItem) then
        return false
    elseif not AreSecretsShown() then
        local properties = GetProtectedTableReferenceField(historyItem, "properties")
        local isSecret = GetProtectedNullableField(properties, "isSecret")
        if isSecret ~= nil and isSecret then
            return false
        elseif isConcernsOrMentionsUnrevealed(historyItem) then
            return false
        else
            return true
        end
    else
        return true
    end
end
