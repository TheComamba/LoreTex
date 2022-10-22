local labelToProcessedEntity = {}

local function registerProcessedEntityLabels(labels, entity)
    if type(labels) ~= "table" then
        labels = { labels }
    end
    for key, label in pairs(labels) do
        labelToProcessedEntity[label] = entity
    end
end

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
    elseif not IsType("places", parent) and not IsEmpty(location) and location ~= targetLocation then
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

local function getRelationship(child, parentLabels)
    for key, parentAndRelationship in pairs(child["parents"]) do
        if IsIn(parentAndRelationship[1], parentLabels) then
            if parentAndRelationship[2] ~= nil then
                return parentAndRelationship[2]
            end
            break
        end
    end
    return ""
end

local function addChildrenDescriptorsToParent(parent)
    StartBenchmarking("addChildrenDescriptorsToParent")
    local childrenLabels = parent["children"]
    if childrenLabels == nil then
        StopBenchmarking("addChildrenDescriptorsToParent")
        return
    end
    local parentLabels = GetLabels(parent)
    for key, childLabel in pairs(childrenLabels) do
        local child = GetEntity(childLabel)
        if IsEntityShown(child) then
            local relationship = getRelationship(child, parentLabels)
            addSingleChildDescriptorToParent(child, parent, relationship)
        end
    end
    StopBenchmarking("addChildrenDescriptorsToParent")
end

function AddAutomatedDescriptors(entity)
    StartBenchmarking("AddAutomatedDescriptors")
    AddParentDescriptorsToChild(entity)
    addChildrenDescriptorsToParent(entity)
    AddSpeciesAndAgeStringToNPC(entity)
    AddLifeStagesToSpecies(entity)
    ProcessHistory(entity)
    StopBenchmarking("AddAutomatedDescriptors")
end

function IsEntityInProcessed(label)
    return labelToProcessedEntity[label] ~= nil
end

local function addProcessedEntity(entities, entity, mentionedRefs)
    if not IsEntityInProcessed(GetMainLabel(entity)) then
        local newEntity = DeepCopy(entity)
        MarkDead(newEntity)
        MarkSecret(newEntity)
        AddAutomatedDescriptors(newEntity)
        entities[#entities + 1] = newEntity
        registerProcessedEntityLabels(GetLabels(newEntity), newEntity)
        local mentionedRefsHere = ScanContentForMentionedRefs(newEntity)
        for key, label in pairs(mentionedRefsHere) do
            local mentionedEntity = GetMutableEntityFromAll(label)
            local typeName = mentionedEntity["type"]
            if IsEntityShown(mentionedEntity) and IsIn(typeName, PrimaryRefWhenMentionedTypes) then
                addProcessedEntity(entities, mentionedEntity, mentionedRefs)
            end
        end
        UniqueAppend(mentionedRefs, mentionedRefsHere)
    end
end

function ProcessEntities(entitiesIn)
    StartBenchmarking("ProcessEntities")
    labelToProcessedEntity = {}
    local entitiesOut = {}
    local primaryEntities = GetEntitiesIf(IsPrimary, entitiesIn)
    local visibleEntities = GetEntitiesIf(IsEntityShown, primaryEntities)
    local mentionedRefsHere = DeepCopy(MentionedRefs)
    for key, entity in pairs(visibleEntities) do
        StartBenchmarking("addProcessedEntity")
        addProcessedEntity(entitiesOut, entity, mentionedRefsHere)
        StopBenchmarking("addProcessedEntity")
    end
    StopBenchmarking("ProcessEntities")
    return entitiesOut, mentionedRefsHere
end
