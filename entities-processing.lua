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
    if not IsEmpty(relationship) and not IsProtectedDescriptor(relationship) then
        Append(content, relationship)
    end
    local birthyearstr = GetProtectedField(child, "born")
    local birthyear = tonumber(birthyearstr)
    if not IsEmpty(birthyear) and birthyear <= CurrentYear then
        birthyear = ConvertYearFromVin(birthyear, YearFmt)
        Append(content, TexCmd("textborn") .. birthyear)
    end
    local deathyearstr = GetProtectedField(child, "died")
    local deathyear = tonumber(deathyearstr)
    if not IsEmpty(deathyear) and deathyear <= CurrentYear then
        deathyear = ConvertYearFromVin(deathyear, YearFmt)
        Append(content, TexCmd("textdied") .. deathyear)
    end
    local location = GetProtectedField(child, "location")
    local targetLocation = GetProtectedField(parent, "location")
    if IsLocationUnrevealed(child) then
        Append(content, Tr("at-secret-location"))
    elseif not IsEmpty(location) and location ~= targetLocation and not IsIn(location, GetLabels(parent)) then
        Append(content, Tr("in") .. " " .. TexCmd("nameref", location))
    end
    if not IsEmpty(content) then
        return "(" .. table.concat(content, ", ") .. ")"
    else
        return ""
    end
end

local function addSingleChildDescriptorToParent(child, parent, relationship)
    local childType = GetProtectedField(child, "type")
    local descriptor = Tr("affiliated") .. " " .. Tr(childType)
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
    local parents = GetProtectedField(child, "parents")
    for key, parentAndRelationship in pairs(parents) do
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
    local childrenLabels = GetProtectedField(parent, "children")
    if childrenLabels == nil then
        childrenLabels = {}
    end
    table.sort(childrenLabels, CompareByName)
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

local function addPrimariesWhenMentioned(entities, mentionedRefsHere, allMentionedRefs)
    for key, label in pairs(mentionedRefsHere) do
        local mentionedEntity = GetEntity(label)
        local typeName = GetProtectedField(mentionedEntity, "type")
        if IsIn(typeName, PrimaryRefWhenMentionedTypes) then
            AddProcessedEntity(entities, mentionedEntity, allMentionedRefs)
        end
    end
end

function AddProcessedEntity(entities, entity, allMentionedRefs)
    if IsEntityShown(entity) and not IsEntityInProcessed(GetMainLabel(entity)) then
        local newEntity = DeepCopy(entity)
        MarkDead(newEntity)
        MarkSecret(newEntity)
        AddAutomatedDescriptors(newEntity)
        entities[#entities + 1] = newEntity
        registerProcessedEntityLabels(GetLabels(newEntity), newEntity)
        local mentionedRefsHere = ScanContentForMentionedRefs(newEntity)
        addPrimariesWhenMentioned(entities, mentionedRefsHere, allMentionedRefs)
        UniqueAppend(allMentionedRefs, mentionedRefsHere)
    end
end

function ProcessEntities(entitiesIn)
    StartBenchmarking("ProcessEntities")
    labelToProcessedEntity = {}
    local entitiesOut = {}
    local primaryEntities = GetEntitiesIf(IsPrimary, entitiesIn)
    local mentionedRefsHere = DeepCopy(MentionedRefs)
    addPrimariesWhenMentioned(entitiesOut, mentionedRefsHere, mentionedRefsHere)
    for key, entity in pairs(primaryEntities) do
        StartBenchmarking("addProcessedEntity")
        AddProcessedEntity(entitiesOut, entity, mentionedRefsHere)
        StopBenchmarking("addProcessedEntity")
    end
    StopBenchmarking("ProcessEntities")
    return entitiesOut, mentionedRefsHere
end
