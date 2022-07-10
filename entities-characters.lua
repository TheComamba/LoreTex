CharacterTypes = { "pc", "npc", "god" }
CharacterTypeNames = { "Spielercharaktere", "NPCs", "Götter" }
PCs = {}

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
        if location ~= nil then
            if Entities[location] == nil then
                LogError("Location \"" .. location .. "\" not found in entities.")
            elseif not IsPlace(Entities[location]) then
                LogError("Location \"" .. location .. "\" is not a place.")
            else
                if Entities[location]["NPCs"] == nil then
                    Entities[location]["NPCs"] = {}
                end
                Entities[location]["NPCs"][#Entities[location]["NPCs"] + 1] = TexCmd("nameref", label)
            end
        end
    end
end

function AddNPCsToAssociations()
    local npcs = GetEntitiesIf(IsChar)
    for label, char in pairs(npcs) do
        local association = char["association"]
        if association ~= nil then
            if Entities[association] == nil then
                LogError("Association \"" .. association .. "\" not found in entities.")
            elseif not IsAssociation(Entities[association]) then
                LogError("Association \"" .. association .. "\" is not an association.")
            else
                if Entities[association]["NPCs"] == nil then
                    Entities[association]["NPCs"] = {}
                end
                Entities[association]["NPCs"][#Entities[association]["NPCs"] + 1] = TexCmd("nameref", label)
            end
        end
    end
end

function AddSpeciesAndAgeStringToNPCs()
    local npcs = GetEntitiesIf(IsChar)
    for label, char in pairs(npcs) do
        SetDescriptor(label, "Erscheinung", SpeciesAndAgeString(char), "Spezies und Alter")
    end
end
