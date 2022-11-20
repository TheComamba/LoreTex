local labelToProcessedEntity = {}

local function registerProcessedEntityLabels(labels, entity)
    if type(labels) ~= "table" then
        labels = { labels }
    end
    for key, label in pairs(labels) do
        labelToProcessedEntity[label] = entity
    end
end

local function entityQualifiersString(child, parent, relationships)
    local content = {}
    if IsEntitySecret(child) then
        Append(content, Tr("secret"))
    end
    for key, relationship in pairs(relationships) do
        Append(content, relationship)
    end
    local birthyearstr = GetProtectedNullableField(child, "born")
    local birthyear = tonumber(birthyearstr)
    if not IsEmpty(birthyear) and birthyear <= GetCurrentYear() then
        birthyear = AddYearOffset(birthyear, YearFmt)
        Append(content, TexCmd("textborn") .. birthyear)
    end
    local deathyearstr = GetProtectedNullableField(child, "died")
    local deathyear = tonumber(deathyearstr)
    if not IsEmpty(deathyear) and deathyear <= GetCurrentYear() then
        deathyear = AddYearOffset(deathyear, YearFmt)
        Append(content, TexCmd("textdied") .. deathyear)
    end
    local childLocation = GetProtectedNullableField(child, "location")
    local parentLocation = GetProtectedNullableField(parent, "location")
    if IsLocationUnrevealed(child) then
        Append(content, Tr("at-secret-location"))
    elseif not IsEmpty(childLocation) then
        local childLocationLabel = GetMainLabel(childLocation)
        local parentLocationLabel = ""
        if not IsEmpty(parentLocation) then
            parentLocationLabel = GetMainLabel(parentLocation)
        end
        if childLocationLabel ~= parentLocationLabel and
            not IsIn(childLocationLabel, GetProtectedTableField(parent, "labels")) then
            Append(content, Tr("in") .. " " .. TexCmd("nameref", childLocationLabel))
        end
    end
    if not IsEmpty(content) then
        return "(" .. table.concat(content, ", ") .. ")"
    else
        return ""
    end
end

local function addSingleChildDescriptorToParent(child, parent, relationships)
    local childType = GetProtectedStringField(child, "type")
    local descriptor = Tr("affiliated") .. " " .. Tr(childType)
    if parent[descriptor] == nil then
        parent[descriptor] = {}
    end
    local content = {}
    local srcLabel = GetMainLabel(child)
    Append(content, TexCmd("nameref", srcLabel))
    Append(content, " ")
    Append(content, entityQualifiersString(child, parent, relationships))
    UniqueAppend(parent[descriptor], table.concat(content))
end

local function getRelationships(child, parent)
    local parents = GetProtectedTableField(child, "parents")
    local relationships = {}
    for key, parentAndRelationship in pairs(parents) do
        if GetMainLabel(parentAndRelationship[1]) == GetMainLabel(parent) then
            local relationship = parentAndRelationship[2]
            if not IsEmpty(relationship) and not IsProtectedDescriptor(relationship) then
                UniqueAppend(relationships, parentAndRelationship[2])
            end
        end
    end
    table.sort(relationships)
    return relationships
end

local function addChildrenDescriptorsToParent(parent)
    StartBenchmarking("addChildrenDescriptorsToParent")
    local children = GetProtectedTableField(parent, "children")
    Sort(children, "compareByName")
    for key, child in pairs(children) do
        if IsEntityShown(child) then
            local relationships = getRelationships(child, parent)
            addSingleChildDescriptorToParent(child, parent, relationships)
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

local function isEntityInProcessed(label)
    return labelToProcessedEntity[label] ~= nil
end

local function addPrimariesWhenMentioned(arg, mentionedRefsHere)
    for key, label in pairs(mentionedRefsHere) do
        local mentionedEntity = GetEntity(label)
        local typeName = GetProtectedStringField(mentionedEntity, "type")
        if IsIn(typeName, PrimaryRefWhenMentionedTypes) then
            AddProcessedEntity(arg, mentionedEntity)
        end
    end
end

local function addEntityToDict(arg, newEntity)
    if arg.entites == nil then
        arg.entites = {}
    end
    local typename = GetProtectedStringField(newEntity, "type")
    local metatype = GetMetatype(typename)
    if arg.entities[metatype] == nil then
        arg.entities[metatype] = {}
    end
    if arg.entities[metatype][typename] == nil then
        arg.entities[metatype][typename] = {}
    end
    local locationName = ""
    if IsLocationUnrevealed(newEntity) then
        locationName = GetProtectedDescriptor("isSecret")
    else
        local location = GetProtectedNullableField(newEntity, "location")
        if not IsEmpty(location) then
            locationName = PlaceToName(location)
        end
    end
    if arg.entities[metatype][typename][locationName] == nil then
        arg.entities[metatype][typename][locationName] = {}
    end
    arg.entities[metatype][typename][locationName][#arg.entities[metatype][typename][locationName] + 1] = newEntity
end

local function processEntity(arg, entity)
    local newEntity = DeepCopy(entity)
    MarkDead(newEntity)
    MarkSecret(newEntity)
    AddAutomatedDescriptors(newEntity)
    addEntityToDict(arg, newEntity)
    registerProcessedEntityLabels(GetProtectedTableField(newEntity, "labels"), newEntity)
    local mentionedRefsHere = ScanContentForMentionedRefs(newEntity)
    addPrimariesWhenMentioned(arg, mentionedRefsHere)
    UniqueAppend(arg.mentionedRefs, mentionedRefsHere)
end

function AddProcessedEntity(arg, entity)
    local superEntity = GetProtectedNullableField(entity, "partOf")
    if superEntity ~= nil then
        AddProcessedEntity(arg, superEntity)
    elseif IsEntityShown(entity) and not isEntityInProcessed(GetMainLabel(entity)) then
        processEntity(arg, entity)
    end
end

local function removeProcessedEntities(mentionedRefs)
    local onlyMentioned = {}
    for key, label in pairs(mentionedRefs) do
        if not isEntityInProcessed(label) then
            UniqueAppend(onlyMentioned, label)
        end
    end
    return onlyMentioned
end

function ProcessEntities()
    StartBenchmarking("ProcessEntities")
    labelToProcessedEntity = {}
    local out = {}
    out.entities = {}
    out.mentionedRefs = DeepCopy(MentionedRefs)
    local primaryEntities = GetEntitiesIf(IsPrimary, AllEntities)
    addPrimariesWhenMentioned(out, out.mentionedRefs)
    for key, entity in pairs(primaryEntities) do
        StartBenchmarking("addProcessedEntity")
        AddProcessedEntity(out, entity)
        StopBenchmarking("addProcessedEntity")
    end
    out.mentionedRefs = removeProcessedEntities(out.mentionedRefs)
    StopBenchmarking("ProcessEntities")
    return out
end
