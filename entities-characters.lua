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

function AddSpeciesAndAgeStringToNPCs(entities)
    local npcs = GetEntitiesIf(IsChar, entities)
    for key, char in pairs(npcs) do
        SetDescriptor(char, "Erscheinung", SpeciesAndAgeString(char, CurrentYearVin), "Spezies und Alter:")
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

function MarkDead(entities)
    for key, entity in pairs(entities) do
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

local function getYear(entity, key)
    local value = entity[key]
    if value == nil then
        return nil
    end
    local year = tonumber(value)
    if year == nil then
        LogError("Could not convert " .. DebugPrint(value) .. " to year in entity: " .. DebugPrint(entity))
        return nil
    else
        return year
    end
end

function GetAgeInYears(entity, year)
    if year == nil or type(year) ~= "number" then
        LogError("Called with " .. DebugPrint(year))
        return nil
    end
    local born = getYear(entity, "born")
    local died = getYear(entity, "died")
    if born == nil then
        return nil
    elseif died == nil or died > year then
        return year - born
    else
        return died - born
    end
end
