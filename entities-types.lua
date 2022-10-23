AllTypes = {}
AllTypes["associations"] = { "families", "organisations" }
AllTypes["characters"] = { "gods", "npcs", "pcs" }
AllTypes["chronologies"] = { "events", "stories" }
AllTypes["classes"] = { "classes", "subclasses" }
AllTypes["items"] = { "artefacts", "items", "ships" }
AllTypes["landmarks"] = { "forests", "glaciers", "grasslands", "lakes", "mountainranges", "mountains", "rivers" }
AllTypes["magic"] = { "spells", "spell-properties" }
AllTypes["other"] = { "other" }
AllTypes["peoples"] = { "languages", "species" }
AllTypes["places"] = { "places" }

function IsType(type, entity)
    local entityType = entity["type"]
    if IsEmpty(entity) or entityType == nil then
        return false
    else
        local types = AllTypes[type]
        if types == nil then
            return entityType == type
        else
            return IsIn(entityType, types)
        end
    end
end

function IsTypeKnown(queriedType)
    for key1, types in pairs(AllTypes) do
        for key2, type in pairs(types) do
            if type == queriedType then
                return true
            end
        end
    end
    return false
end

function SortedMetatypes()
    local metatypes = {}
    for key, types in pairs(AllTypes) do
        Append(metatypes, key)
    end
    table.sort(metatypes, SortByTranslation)
    return metatypes
end
