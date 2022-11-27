local labelToProcessedEntity = {}

local function registerProcessedEntityLabels(entity)
    StartBenchmarking("registerProcessedEntityLabels")
    for key, label in pairs(GetAllLabels(entity)) do
        labelToProcessedEntity[label] = entity
    end
    StopBenchmarking("registerProcessedEntityLabels")
end

local function collectConernedEntities(entity)
    StartBenchmarking("collectConernedEntities")
    local out = GetProtectedTableField(entity, "concerns")
    for key, item in pairs(GetProtectedTableField(entity, "historyItems")) do
        for key2, concern in pairs(GetProtectedTableField(item, "concerns")) do
            out[#out + 1] = concern
        end
    end
    for key, sub in pairs(GetProtectedTableField(entity, "subEntities")) do
        for key2, concern in pairs(collectConernedEntities(sub)) do
            out[#out + 1] = concern
        end
    end
    StopBenchmarking("collectConernedEntities")
    return out
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
        local childLocationLabel = GetProtectedStringField(childLocation, "label")
        local parentLocationLabel = ""
        if not IsEmpty(parentLocation) then
            parentLocationLabel = GetProtectedStringField(parentLocation, "label")
        end
        if childLocationLabel ~= parentLocationLabel and
            not IsIn(childLocationLabel, GetAllLabels(parent)) then
            Append(content, Tr("in") .. " " .. TexCmd("nameref", childLocationLabel))
            AddToProtectedField(parent, "concerns", childLocation)
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
    local srcLabel = GetProtectedStringField(child, "label")
    Append(content, TexCmd("nameref", srcLabel))
    Append(content, " ")
    Append(content, entityQualifiersString(child, parent, relationships))
    UniqueAppend(parent[descriptor], table.concat(content))
end

local function getRelationships(child, parent)
    local parents = GetProtectedTableField(child, "parents")
    local relationships = {}
    for key, parentAndRelationship in pairs(parents) do
        local affiliationLabel = GetProtectedStringField(parentAndRelationship[1], "label")
        local parentLabel = GetProtectedStringField(parent, "label")
        if affiliationLabel == parentLabel then
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

function AddSubEntitiesAsDescriptors(entity)
    for key, sub in pairs(GetProtectedTableField(entity, "subEntities")) do
        local descriptor = GetProtectedStringField(sub, "name")
        local description = { GetProtectedStringField(sub, "content") }
        local subsubs = GetProtectedTableField(sub, "subEntities")
        for key2, subsub in pairs(subsubs) do
            local content = GetProtectedStringField(subsub, "content")
            Append(description, content)
        end
        entity[descriptor] = table.concat(description)
    end
end

function AddAutomatedDescriptors(entity)
    StartBenchmarking("AddAutomatedDescriptors")
    AddParentDescriptorsToChild(entity)
    addChildrenDescriptorsToParent(entity)
    AddSpeciesAndAgeStringToNPC(entity)
    AddLifeStagesToSpecies(entity)
    ProcessHistory(entity)
    AddSubEntitiesAsDescriptors(entity)
    StopBenchmarking("AddAutomatedDescriptors")
end

function IsEntityProcessed(label)
    return labelToProcessedEntity[label] ~= nil
end

local function addPrimariesWhenMentioned(arg, mentioned)
    StartBenchmarking("addPrimariesWhenMentioned")
    for key, entity in pairs(mentioned) do
        local typeName = GetProtectedStringField(entity, "type")
        if IsIn(typeName, PrimaryRefWhenMentionedTypes) then
            AddProcessedEntity(arg, entity)
        end
    end
    StopBenchmarking("addPrimariesWhenMentioned")
end

local function addEntityToDict(arg, newEntity)
    StartBenchmarking("addEntityToDict")
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
    StopBenchmarking("addEntityToDict")
end

local function processEntity(entity)
    StartBenchmarking("processEntity")
    local newEntity = DeepCopy(entity)
    MarkDead(newEntity)
    MarkSecret(newEntity)
    AddAutomatedDescriptors(newEntity)
    StopBenchmarking("processEntity")
    return newEntity
end

local function registerProcessedEntity(arg, newEntity)
    StartBenchmarking("registerProcessedEntity")
    addEntityToDict(arg, newEntity)
    registerProcessedEntityLabels(newEntity)
    StopBenchmarking("registerProcessedEntity")
end

local function addFollowUpEntities(arg, newEntity)
    StartBenchmarking("addFollowUpEntities")
    local mentionedEntities = collectConernedEntities(newEntity)
    addPrimariesWhenMentioned(arg, mentionedEntities)
    for key, mentionedEntity in pairs(mentionedEntities) do
        if not IsEntityUnrevealed(mentionedEntity) then
            arg.mentioned[#arg.mentioned + 1] = mentionedEntity
        end
    end
    StopBenchmarking("addFollowUpEntities")
end

function AddProcessedEntity(arg, entity)
    StartBenchmarking("AddProcessedEntity")
    local superEntity = GetProtectedNullableField(entity, "partOf")
    if superEntity ~= nil then
        AddProcessedEntity(arg, superEntity)
    elseif IsEntityShown(entity) and not IsEntityProcessed(GetProtectedStringField(entity, "label")) then
        local newEntity = processEntity(entity)
        registerProcessedEntity(arg, newEntity)
        addFollowUpEntities(arg, newEntity)
    end
    StopBenchmarking("AddProcessedEntity")
end

local function getPrimaryEntities()
    StartBenchmarking("getPrimaryEntities")
    local out = {}
    for key, label in pairs(PrimaryRefs) do
        out[#out + 1] = GetEntity(label)
    end
    StopBenchmarking("getPrimaryEntities")
    return out
end

function ProcessEntities()
    StartBenchmarking("ProcessEntities")
    labelToProcessedEntity = {}
    local out = {}
    out.entities = {}
    local primaryEntities = getPrimaryEntities()
    out.mentioned = {}
    for key, label in pairs(MentionedRefs) do
        out.mentioned[#out.mentioned + 1] = GetEntity(label)
    end
    addPrimariesWhenMentioned(out, out.mentioned)
    for key, entity in pairs(primaryEntities) do
        AddProcessedEntity(out, entity)
    end
    StopBenchmarking("ProcessEntities")
    return out
end
