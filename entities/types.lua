AllTypes = {}

StateResetters[#StateResetters + 1] = function()
    AllTypes = {}
    AllTypes["associations"] = { "families", "organisations" }
    AllTypes["characters"] = { "gods", "npcs", "pcs" }
    AllTypes["chronologies"] = { "calendars", "events", "stories" }
    AllTypes["classes"] = { "classes", "subclasses" }
    AllTypes["things"] = { "artefacts", "items", "vehicles" }
    AllTypes["landmarks"] = { "forests", "glaciers", "grasslands", "lakes", "mountainranges", "mountains", "rivers" }
    AllTypes["magic"] = { "spells", "spell-properties" }
    AllTypes["other"] = { "other" }
    AllTypes["peoples"] = { "languages", "species" }
    AllTypes["places"] = { "places" }
end

function IsType(type, entity)
    local entityType = GetProtectedStringField(entity, "type")
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

function GetMetatype(typename)
    for metatype, types in pairs(AllTypes) do
        if IsIn(typename, types) then
            return metatype
        end
    end
    LogError("Type \"" .. typename .. "\" not found!")
    return ""
end

function SortedMetatypes()
    local metatypes = {}
    for key, types in pairs(AllTypes) do
        Append(metatypes, key)
    end
    Sort(metatypes, "compareTranslation")
    return metatypes
end

function PrintAllTypes()
    local out = {}
    local metatypes = SortedMetatypes()
    if #metatypes > 0 then
        Append(out, TexCmd("begin", "itemize"))
        for i, metatype in pairs(metatypes) do
            Append(out, TexCmd("item"))
            Append(out, metatype)
            local types = DeepCopy(AllTypes[metatype])
            if #types > 0 then
                Append(out, TexCmd("begin", "itemize"))
                for j, type in pairs(types) do
                    Append(out, TexCmd("item"))
                    Append(out, type)
                end
                Append(out, TexCmd("end", "itemize"))
            end
        end
        Append(out, TexCmd("end", "itemize"))
    else
        tex.print("There are no types.")
    end
    tex.print(out)
end
