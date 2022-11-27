IsShowFuture = true
IsShowSecrets = false
RevealedLabels = {}

StateResetters[#StateResetters + 1] = function()
    IsShowFuture = true
    IsShowSecrets = false
    RevealedLabels = {}
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

function IsEntityUnrevealed(entity)
    if IsShowSecrets then
        return false
    end
    return IsEntitySecret(entity) and (not IsRevealed(entity))
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

function IsLocationUnrevealed(entity)
    local location = GetProtectedNullableField(entity, "location")
    return IsEntityUnrevealed(location)
end

local function concernesAndMentions(historyItem)
    local out = GetProtectedTableField(historyItem, "concerns")
    for key, mentions in pairs(GetProtectedTableField(historyItem, "mentions")) do
        out[#out + 1] = mentions
    end
    return out
end

local function isConcernsOrMentionsUnrevealed(historyItem)
    for key, entity in pairs(concernesAndMentions(historyItem)) do
        if IsEntitySecret(entity) and not IsRevealed(entity) then
            return true
        end
    end
    return false
end

function IsConcernsOrMentionsSecret(historyItem)
    for key, entity in pairs(concernesAndMentions(historyItem)) do
        if IsEntitySecret(entity) then
            return true
        end
    end
    return false
end

local function isAllConcnernsAndMentionsShown(historyItem)
    for key, entity in pairs(concernesAndMentions(historyItem)) do
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
    elseif not IsShowFuture and IsFutureEvent(historyItem) then
        return false
    elseif not IsShowSecrets then
        local isSecret = GetProtectedNullableField(historyItem, "isSecret")
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
