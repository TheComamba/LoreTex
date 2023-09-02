local allCategories = {}

StateResetters[#StateResetters + 1] = function()
    allCategories = {}
end

function HasCategory(category, entity)
    local entityCategory = GetProtectedStringField(entity, "category")
    return category == entityCategory
end

function IsCategoryKnown(queriedCategory)
    return IsIn(queriedCategory, allCategories)
end

function AddCategory(category)
    UniqueAppend(allCategories, category)
end

function GetSortedCategories()
    Sort(allCategories, "compareAlphanumerical")
    return allCategories
end
