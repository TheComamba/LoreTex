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
    for key, char in pairs(npcs) do
        SetDescriptor(char, "Erscheinung", SpeciesAndAgeString(char), "Spezies und Alter:")
    end
end

local function isHasHappened(entity, keyword, onNil)
    if entity == nil then
        return onNil
    end
    if type(entity) ~= "table" then
        LogError("Called with: " .. DebugPrint(entity))
        return onNil
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

function MarkDead()
    for key, entity in pairs(Entities) do
        if IsEmpty(entity["name"]) then
            LogError("Entity at position " .. key .. " has no name!")
        elseif IsDead(entity) then
            if entity["shortname"] == nil then
                entity["shortname"] = entity["name"]
            end
            entity["name"] = entity["name"] .. " " .. TexCmd("textdied")
        end
    end
end
