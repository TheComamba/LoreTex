function CompareStrings(a, b)
    if type(a) == "string" and type(b) == "string" then
        if a:lower() == b:lower() then
            return a < b
        else
            return a:lower() < b:lower()
        end
    elseif type(a) == type(b) then
        return a < b
    elseif type(a) == "number" and type(b) == "string" then
        return true --numbers before strings
    elseif type(a) == "string" and type(b) == "number" then
        return false --numbers before strings
    end

    LogError("Tried comparing " .. DebugPrint(a) .. " with " .. DebugPrint(b))
    return true
end

function CompareByName(entity1, entity2)
    if type(entity1) == "table" then
        return CompareStrings(GetShortname(entity1), GetShortname(entity2))
    elseif type(entity1) == "string" then
        return CompareStrings(LabelToName(entity1), LabelToName(entity2))
    end
end

function CompareAffiliations(a, b)
    if a[1] ~= b[1] then
        return CompareByName(a[1], b[1])
    elseif #a ~= #b then
        return #a < #b
    elseif #a > 1 then
        return a[2] < b[2]
    else
        return false
    end
end

function CompareHistoryItems(a, b)
    if a["year"] ~= b["year"] then
        return a["year"] < b["year"]
    elseif a["day"] == nil and b["day"] == nil then
        if a["counter"] == nil or b["counter"] == nil then
            LogError("TODO: Properly process lifestage history items.")
            return false
        end
        return a["counter"] < b["counter"]
    elseif b["day"] == nil then
        return false
    elseif a["day"] == nil then
        return true
    elseif a["day"] ~= b["day"] then
        return a["day"] < b["day"]
    else
        return a["counter"] < b["counter"]
    end
end

function CompareLocationLabelsByName(label1, label2)
    local name1 = PlaceToName(label1)
    local name2 = PlaceToName(label2)
    return CompareStrings(name1, name2)
end

function CompareTranslation(a, b)
    return CompareStrings(Tr(a), Tr(b))
end
