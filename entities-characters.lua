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

function AddSpeciesAndAgeStringToNPCs()
    local npcs = GetEntitiesIf(IsChar)
    for label, char in pairs(npcs) do
        SetDescriptor(label, "Erscheinung", SpeciesAndAgeString(char), "Spezies und Alter:")
    end
end

local function isHasHappened(entity, keyword, onNil)
    if entity == nil then
        return onNil
    end
    if type(entity) == "string" then
        return isHasHappened(Entities[entity], keyword, onNil)
    end
    local year = entity[keyword]
    if year == nil then
        return onNil
    else
        year = tonumber(year)
        if year == nil then
            LogError("Entry with key \"" .. keyword .. "\" of " .. entity["name"] .. " is not a number.")
            return onNil
        end
        return year <= CurrentYearVin
    end
end

function IsBorn(entity)
    return isHasHappened(entity, "born", true)
end

function IsDead(entity)
    return isHasHappened(entity, "died", false)
end

function DeleteUnborn()
    for key, entity in pairs(Entities) do
        if not IsBorn(entity) then
            Entities[key] = nil
        end
    end
end