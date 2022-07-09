CharacterTypes = { "pc", "npc", "god" }
CharacterTypeNames = { "Spielercharaktere", "NPCs", "Götter" }

function IsChar(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], CharacterTypes)
end

function AddNPCsToPlaces()
    local npcs = GetEntitiesIf(IsChar)
    for label, char in pairs(npcs) do
        local location = char["location"]
        if location ~= nil and Entities[location] ~= nil then
            if Entities[location]["NPCs"] == nil then
                Entities[location]["NPCs"] = {}
            end
            Entities[location]["NPCs"][#Entities[location]["NPCs"] + 1] = TexCmd("nameref", label)
        end
    end
end

function AddSpeciesAndAgeStringToNPCs()
    local npcs = GetEntitiesIf(IsChar)
    for label, char in pairs(npcs) do
        SetDescriptor(label, "Erscheinung", SpeciesAndAgeString(char), "Spezies und Alter")
    end
end
