Comparer = {}

local function substringUntil(str, start, pattern)
    local pos = string.find(str, pattern, start)
    if pos == nil then
        return string.sub(str, start), -1
    else
        return string.sub(str, start, pos - 1), pos
    end
end

Comparer.compareString = function(a, b)
    if a:lower() == b:lower() then
        return a < b
    else
        local posA = 1
        local posB = 1
        local subA = ""
        local subB = ""
        while posA > 0 and posB > 0 do
            for key, pattern in pairs({ "%d", "%D" }) do
                subA, posA = substringUntil(a, posA, pattern)
                subB, posB = substringUntil(b, posB, pattern)
                if subA:lower() ~= subB:lower() then
                    if tonumber(subA) ~= nil and tonumber(subB) ~= nil then
                        return tonumber(subA) < tonumber(subB)
                    else
                        return subA:lower() < subB:lower()
                    end
                end
            end
        end
        return a:lower() < b:lower()
    end
end

Comparer.compareAlphanumerical = function(a, b)
    if type(a) == "string" and tonumber(a) ~= nil then
        return Comparer.compareAlphanumerical(tonumber(a), b)
    elseif type(b) == "string" and tonumber(b) ~= nil then
        return Comparer.compareAlphanumerical(a, tonumber(b))
    elseif type(a) == "string" and type(b) == "string" then
        return Comparer.compareString(a, b)
    elseif type(a) == "number" and type(b) == "number" then
        return a < b
    elseif type(a) == "number" and type(b) == "string" then
        return true --numbers before strings
    elseif type(a) == "string" and type(b) == "number" then
        return false --numbers before strings
    end

    LogError("Tried comparing " .. DebugPrint(a) .. " with " .. DebugPrint(b))
    return false
end

Comparer.compareByName = function(entity1, entity2)
    if type(entity1) == "table" then
        return Comparer.compareString(GetShortname(entity1), GetShortname(entity2))
    elseif type(entity1) == "string" then
        return Comparer.compareString(LabelToName(entity1), LabelToName(entity2))
    end
end

Comparer.compareAffiliations = function(a, b)
    if a[1] ~= b[1] then
        return Comparer.compareByName(a[1], b[1])
    elseif #a ~= #b then
        return #a < #b
    elseif #a > 1 then
        return Comparer.compareString(a[2], b[2])
    else
        return false
    end
end

Comparer.compareHistoryItems = function(a, b)
    local yearA = GetProtectedNullableField(a, "year")
    local yearB = GetProtectedNullableField(b, "year")
    local dayA = GetProtectedNullableField(a, "day")
    local dayB = GetProtectedNullableField(b, "day")
    local labelA = GetProtectedNullableField(a, "label")
    local labelB = GetProtectedNullableField(b, "label")
    if yearA ~= yearB then
        return yearA < yearB
    elseif dayA == nil and dayB == nil then
        return Comparer.compareString(labelA, labelB)
    elseif dayB == nil then
        return false
    elseif dayA == nil then
        return true
    elseif dayA ~= dayB then
        return dayA < dayB
    else
        return Comparer.compareString(labelA, labelB)
    end
end

Comparer.compareTranslation = function(a, b)
    return Comparer.compareString(Tr(a), Tr(b))
end

function Sort(t, comp)
    table.sort(t, Comparer[comp])
end
