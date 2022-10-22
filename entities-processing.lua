local function entityQualifiersString(child, parent, relationship)
    local content = {}
    if IsEntitySecret(child) then
        Append(content, Tr("secret"))
    end
    if not IsEmpty(relationship) then
        Append(content, relationship)
    end
    local birthyearstr = child["born"]
    local birthyear = tonumber(birthyearstr)
    if not IsEmpty(birthyear) and birthyear <= CurrentYearVin then
        birthyear = ConvertYearFromVin(birthyear, YearFmt)
        Append(content, TexCmd("textborn") .. birthyear)
    end
    local deathyearstr = child["died"]
    local deathyear = tonumber(deathyearstr)
    if not IsEmpty(deathyear) and deathyear <= CurrentYearVin then
        deathyear = ConvertYearFromVin(deathyear, YearFmt)
        Append(content, TexCmd("textdied") .. deathyear)
    end
    local location = child["location"]
    local targetLocation = parent["location"]
    if IsLocationUnrevealed(child) then
        Append(content, Tr("at-secret-location"))
    elseif not IsPlace(parent) and not IsEmpty(location) and location ~= targetLocation then
        Append(content, Tr("in") .. " " .. TexCmd("nameref", location))
    end
    if not IsEmpty(content) then
        return "(" .. table.concat(content, ", ") .. ")"
    else
        return ""
    end
end

local function addSingleChildDescriptorToParent(child, parent, relationship)
    local childType = child["type"]
    local descriptor = Tr(childType)
    if parent[descriptor] == nil then
        parent[descriptor] = {}
    end
    local content = {}
    local srcLabel = GetMainLabel(child)
    Append(content, TexCmd("nameref", srcLabel))
    Append(content, " ")
    Append(content, entityQualifiersString(child, parent, relationship))
    UniqueAppend(parent[descriptor], table.concat(content))
end

local function addChildrenDescriptorsToParent(parent)
    local childrenLabels = parent["children"]
    if childrenLabels == nil then
        return
    end
    local parentLabels = GetLabels(parent)
    for key, childLabel in pairs(childrenLabels) do
        local child = GetEntity(childLabel)
        if IsEntityShown(child) then
            local relationship = ""
            for key, parentAndRelationship in pairs(child["parents"]) do
                if IsIn(parentAndRelationship[1], parentLabels) then
                    if parentAndRelationship[2] ~= nil then
                        relationship = parentAndRelationship[2]
                    end
                    break
                end
            end
            addSingleChildDescriptorToParent(child, parent, relationship)
        end
    end
end

function AddAutomatedDescriptors(entities)
    ProcessHistory(entities)
    for key, entity in pairs(entities) do
        AddParentDescriptorsToChild(entity)
        addChildrenDescriptorsToParent(entity)
        AddSpeciesAndAgeStringToNPC(entity)
        AddLifeStagesToSpecies(entity)
    end
end

local function isEntityIn(entity, entities)
    if IsEmpty(entities) then
        return false
    end
    local label = GetMainLabel(entity)
    local testEntity = GetMutableEntity(label, entities)
    return not IsEmpty(testEntity)
end

local function addProcessedEntity(entities, entity)
    if not isEntityIn(entity, entities) then
        local newEntity = DeepCopy(entity)
        MarkDead(newEntity)
        MarkSecret(newEntity)
        entities[#entities + 1] = newEntity
    end
end

function ProcessEntities(entitiesIn)
    StartBenchmarking("ProcessEntities")
    local entitiesOut = {}
    local primaryEntities = GetEntitiesIf(IsPrimary, entitiesIn)
    local visibleEntities = GetEntitiesIf(IsEntityShown, primaryEntities)
    for key, entity in pairs(visibleEntities) do
        addProcessedEntity(entitiesOut, entity)
    end

    --TODO: Funktionen für nur eine entity
    AddAutomatedDescriptors(entitiesOut)
    local mentionedRefsHere = DeepCopy(MentionedRefs)
    UniqueAppend(mentionedRefsHere, ScanContentForMentionedRefs(entitiesOut))
    StopBenchmarking("ProcessEntities")
    return entitiesOut, mentionedRefsHere
end
