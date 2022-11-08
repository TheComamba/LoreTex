local function substringUntil(str, start, pattern)
    local pos = string.find(str, pattern, start)
    if pos == nil then
        return string.sub(str, start), -1
    else
        return string.sub(str, start, pos - 1), pos
    end
end

function CompareString(a, b)
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

function CompareAlphanumerical(a, b)
    if type(a) == "string" and tonumber(a) ~= nil then
        return CompareAlphanumerical(tonumber(a), b)
    elseif type(b) == "string" and tonumber(b) ~= nil then
        return CompareAlphanumerical(a, tonumber(b))
    elseif type(a) == "string" and type(b) == "string" then
        return CompareString(a, b)
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

function CompareByName(entity1, entity2)
    if type(entity1) == "table" then
        return CompareString(GetShortname(entity1), GetShortname(entity2))
    elseif type(entity1) == "string" then
        return CompareString(LabelToName(entity1), LabelToName(entity2))
    end
end

function CompareAffiliations(a, b)
    if a[1] ~= b[1] then
        return CompareByName(a[1], b[1])
    elseif #a ~= #b then
        return #a < #b
    elseif #a > 1 then
        return CompareString(a[2], b[2])
    else
        return false
    end
end

function CompareHistoryItems(a, b)
    local yearA = GetProtectedField(a, "year")
    local yearB = GetProtectedField(b, "year")
    local dayA = GetProtectedField(a, "day")
    local dayB = GetProtectedField(b, "day")
    local counterA = GetProtectedField(a, "counter")
    local counterB = GetProtectedField(b, "counter")
    if yearA ~= yearB then
        return yearA < yearB
    elseif dayA == nil and dayB == nil then
        if counterA == nil or counterB == nil then
            LogError("TODO: Properly process lifestage history items.")
            return false
        end
        return counterA < counterB
    elseif dayB == nil then
        return false
    elseif dayA == nil then
        return true
    elseif dayA ~= dayB then
        return dayA < dayB
    else
        return counterA < counterB
    end
end

function CompareLocationLabelsByName(label1, label2)
    local name1 = PlaceToName(label1)
    local name2 = PlaceToName(label2)
    return CompareString(name1, name2)
end

function CompareTranslation(a, b)
    return CompareString(Tr(a), Tr(b))
end
