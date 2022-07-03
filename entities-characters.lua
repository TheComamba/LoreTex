CharacterTypes = { "npc", "pc", "god" }
local Heimatlos = "zzz-heimatlos"

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
            Entities[location]["NPCs"][label] = char["name"]
        end
    end
end

local function createNPCsSortedByPlace()
    local sortedNPCs = {}
    sortedNPCs["labels"] = {}
    local allNpcs = GetEntitiesIf(IsChar)
    for label, char in pairs(allNpcs) do
        local city = char["location"]
        local region = nil

        if city == nil then
            city = Heimatlos
            region = "andere"
        elseif Entities[city] == nil then
            city = "notfound"
            region = "andere"
        elseif Entities[city]["type"] == "region" then
            region = city
            city = Heimatlos
        elseif Entities[city]["parent"] == nil then
            region = "andere"
        else
            region = Entities[city]["parent"]
        end

        if not IsIn(region, sortedNPCs["labels"]) then
            sortedNPCs["labels"][#(sortedNPCs["labels"]) + 1] = region
            sortedNPCs[region] = {}
            sortedNPCs[region]["labels"] = {}
        end
        if not IsIn(city, sortedNPCs[region]["labels"]) then
            sortedNPCs[region]["labels"][#(sortedNPCs[region]["labels"]) + 1] = city
            sortedNPCs[region][city] = {}
            sortedNPCs[region][city]["labels"] = {}
        end
        sortedNPCs[region][city]["labels"][#(sortedNPCs[region][city]["labels"]) + 1] = label
    end
    table.sort(sortedNPCs["labels"])
    for key1, regionLabel in pairs(sortedNPCs["labels"]) do
        tex.print(TexCmd("section", "NPCs in " .. GetShortname(regionLabel)))
        table.sort(sortedNPCs[regionLabel]["labels"])
        for key2, cityLabel in pairs(sortedNPCs[regionLabel]["labels"]) do
            tex.print(TexCmd("subsection", "NPCs in " .. GetShortname(cityLabel)))
            if IsIn(cityLabel, PrimaryRefs) then
                tex.print("Siehe auch " .. TexCmd("nameref", cityLabel) .. ".")
            end
            table.sort(sortedNPCs[regionLabel][cityLabel]["labels"])
            for key3, npcLabel in pairs(sortedNPCs[regionLabel][cityLabel]["labels"]) do
                local npc = Entities[npcLabel]
                tex.print(TexCmd("subsubsection", npc["name"], npc["shortname"]))
                tex.print(TexCmd("label", npcLabel))
                tex.print(SpeciesAndAgeString(npc))
                tex.print(DescriptorsString(npc))
            end
        end
    end
end

function AddPrimaryNPCLocationsToRefs()
    local npcs = GetEntitiesIf(IsChar)
    local primaryNpcs = GetPrimaryRefEntities(npcs)
    for label, npc in pairs(primaryNpcs) do
        local location = npc["location"]
        if location ~= nil then
            AddRef(location, PrimaryRefs)
        end
    end
end

function CreateNPCs()
    tex.print(TexCmd("twocolumn"))
    tex.print(TexCmd("chapter", "NPCs"))
    tex.print(TexCmd("section", "Alle NPCs, alphabetisch sortiert"))
    local npcs = GetEntitiesIf(IsChar)
    tex.print(ListAllFromMap(npcs))
    tex.print(TexCmd("onecolumn"))

    createNPCsSortedByPlace()
end
