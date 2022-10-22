AllTypes = {}
AllTypes["associations"] = { "organisations", "families", "ships" }
AllTypes["characters"] = { "pcs", "npcs", "gods" }
AllTypes["classes"] = { "classes", "subclasses" }
AllTypes["places"] = { "places" }
AllTypes["items"] = { "items" }
AllTypes["landmarks"] = { "forests", "grasslands", "mountainranges", "mountains", "rivers", "glaciers", "lakes" }
AllTypes["languages"] = { "languages" }
AllTypes["species"] = { "species" }
AllTypes["spells"] = { "spells", "spell-properties" }

function IsType(metatype, entity)
    if IsEmpty(entity) or entity["type"] == nil then
        return false
    else
        local types = AllTypes[metatype]
        if types == nil then
            LogError("Called with unknown metatype " .. DebugPrint(metatype))
            return false
        else
            return IsIn(entity["type"], types)
        end
    end
end

function SortedMetatypes()
    local metatypes = {}
    for key, types in pairs(AllTypes) do
        Append(metatypes, key)
    end
    table.sort(metatypes, SortByTranslation)
    return metatypes
end