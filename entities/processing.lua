local labelToProcessedEntity = {}

StateResetters[#StateResetters + 1] = function()
    labelToProcessedEntity = {}
end

local function registerProcessedEntityLabels(entity)
    for key, label in pairs(GetAllLabels(entity)) do
        labelToProcessedEntity[label] = entity
    end
end

local function collectMentionedEntities(entity)
    local out = GetProtectedTableField(entity, "mentions")
    for key, item in pairs(GetProtectedTableField(entity, "historyItems")) do
        for key2, concern in pairs(GetProtectedTableField(item, "mentions")) do
            out[#out + 1] = concern
        end
    end
    for key, sub in pairs(GetProtectedTableField(entity, "subEntities")) do
        for key2, concern in pairs(collectMentionedEntities(sub)) do
            out[#out + 1] = concern
        end
    end
    return out
end

local function addSubEntitiesAsDescriptors(entity)
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

local function addAutomatedDescriptors(entity)
    AddAffiliationDescriptors(entity)
    AddSpeciesAndAgeStringToNPC(entity)
    AddLifeStagesToSpecies(entity)
    ProcessHistory(entity)
    addSubEntitiesAsDescriptors(entity)
end

local function addPrimariesWhenMentioned(arg, mentioned)
    for key, entity in pairs(mentioned) do
        local typeName = GetProtectedStringField(entity, "type")
        if IsIn(typeName, PrimaryRefWhenMentionedTypes) then
            AddProcessedEntity(arg, entity)
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
        local location = GetProtectedInheritableField(newEntity, "location")
        if location ~= nil then
            locationName = PlaceToName(location)
        end
    end
    if arg.entities[metatype][typename][locationName] == nil then
        arg.entities[metatype][typename][locationName] = {}
    end
    arg.entities[metatype][typename][locationName][#arg.entities[metatype][typename][locationName] + 1] = newEntity
end

local function processEntity(entity)
    local newEntity = DeepCopy(entity)
    AddNameMarkers(newEntity)
    addAutomatedDescriptors(newEntity)
    return newEntity
end

local function registerProcessedEntity(arg, newEntity)
    addEntityToDict(arg, newEntity)
    registerProcessedEntityLabels(newEntity)
end

local function addFollowUpEntities(arg, newEntity)
    local mentionedEntities = collectMentionedEntities(newEntity)
    addPrimariesWhenMentioned(arg, mentionedEntities)
    for key, mentionedEntity in pairs(mentionedEntities) do
        if not IsEntityUnrevealed(mentionedEntity) then
            arg.mentioned[#arg.mentioned + 1] = mentionedEntity
        end
    end
end

function AddProcessedEntity(arg, entity)
    local superEntity = GetProtectedNullableField(entity, "partOf")
    if superEntity ~= nil then
        AddProcessedEntity(arg, superEntity)
    elseif IsEntityShown(entity) and not IsEntityProcessed(GetProtectedStringField(entity, "label")) then
        local newEntity = processEntity(entity)
        registerProcessedEntity(arg, newEntity)
        addFollowUpEntities(arg, newEntity)
    end
end

local function getPrimaryEntities()
    local out = {}
    for key, label in pairs(PrimaryRefs) do
        out[#out + 1] = GetEntity(label)
    end
    return out
end

function IsEntityProcessed(label)
    return labelToProcessedEntity[label] ~= nil
end

function ProcessedEntities()
    labelToProcessedEntity = {}
    local out = {}
    out.entities = {}
    local primaryEntities = getPrimaryEntities()
    out.mentioned = {}
    for key, label in pairs(MentionedRefs) do
        out.mentioned[#out.mentioned + 1] = GetEntityRaw(label)
    end
    addPrimariesWhenMentioned(out, out.mentioned)
    for key, entity in pairs(primaryEntities) do
        AddProcessedEntity(out, entity)
    end
    return out
end
