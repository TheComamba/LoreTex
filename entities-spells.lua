SpellTypes = { "spell", "spell-property" }
SpellTypeNames = { "Zauber", "Zauber-Eigenschaften" }

function IsSpell(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], SpellTypes)
end
