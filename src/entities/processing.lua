local labelToProcessedEntity = {}

StateResetters[#StateResetters + 1] = function()
    labelToProcessedEntity = {}
end

local function collectMentionedEntities(entity)
    local out = GetProtectedTableCopyField(entity, "mentions")
    for key, item in pairs(GetProtectedTableReferenceField(entity, "historyItems")) do
        for key2, concern in pairs(GetProtectedTableReferenceField(item, "mentions")) do
            out[#out + 1] = concern
        end
    end
    return out
end

local function addAutomatedDescriptors(entity)
    AddAffiliationDescriptors(entity)
    AddSpeciesAndAgeString(entity)
    AddLifeStages(entity)
    AddHeightDescriptor(entity)
    ProcessHistory(entity)
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
    if arg.entities[typename] == nil then
        arg.entities[typename] = {}
    end
    local locationName = ""
    if IsLocationUnrevealed(newEntity) then
        locationName = GetProtectedDescriptor("isSecret")
    else
        local location = GetProtectedNullableField(newEntity, "location")
        if location ~= nil then
            locationName = PlaceToName(location)
        end
    end
    if arg.entities[typename][locationName] == nil then
        arg.entities[typename][locationName] = {}
    end
    arg.entities[typename][locationName][#arg.entities[typename][locationName] + 1] = newEntity
end

local function registerProcessedEntity(arg, newEntity)
    if GetProtectedNullableField(newEntity, "partOf") == nil then
        addEntityToDict(arg, newEntity)
    end
    local label = GetProtectedStringField(newEntity, "label")
    labelToProcessedEntity[label] = newEntity
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

local function checkType(entity)
    local type = GetProtectedStringField(entity, "type")
    if not IsTypeKnown(type) then
        local label = GetProtectedStringField(entity, "label")
        LogError("Entity \"" .. label .. "\" has unknown type \"" .. type .. "\"")
        SetProtectedField(entity, "type", type:upper())
        TexApi.addType { metatype = "UNKNOWN", type = type:upper() }
    end
end

local function processEntity(arg, entity)
    local newEntity = DeepCopy(entity)
    checkType(newEntity)
    AddNameMarkers(newEntity)
    addAutomatedDescriptors(newEntity)
    for key, val in pairs(entity) do
        if not IsProtectedDescriptor(key) and IsEntity(val) then
            newEntity[key] = processEntity(arg, val)
        end
    end
    registerProcessedEntity(arg, newEntity)
    addFollowUpEntities(arg, newEntity)
    return newEntity
end

function AddProcessedEntity(arg, entity)
    local superEntity = GetProtectedNullableField(entity, "partOf")
    if superEntity ~= nil then
        AddProcessedEntity(arg, superEntity)
    elseif IsEntityShown(entity) and not IsEntityProcessed(GetProtectedStringField(entity, "label")) then
        processEntity(arg, entity)
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
        out.mentioned[#out.mentioned + 1] = GetEntity(label)
    end
    addPrimariesWhenMentioned(out, out.mentioned)
    for key, entity in pairs(primaryEntities) do
        AddProcessedEntity(out, entity)
    end
    return out
end
