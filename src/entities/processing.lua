local labelToProcessedEntity = {}

StateResetters[#StateResetters + 1] = function()
    labelToProcessedEntity = {}
end

local function addAutomatedDescriptors(entity)
    AddAffiliationDescriptors(entity)
    AddSpeciesAndAgeString(entity)
    AddLifeStages(entity)
    AddHeightDescriptor(entity)
    ProcessHistory(entity)
end

local function addPrimariesWhenMentioned(arg, mentioned)
    for _, entity in pairs(mentioned) do
        local categoryName = GetProtectedStringField(entity, "category")
        if IsIn(categoryName, PrimaryRefWhenMentionedCategories) then
            AddProcessedEntity(arg, entity)
        end
    end
end

local function addEntityToDict(arg, newEntity)
    if arg.entities == nil then
        arg.entities = {}
    end
    local categoryname = GetProtectedStringField(newEntity, "category")
    if arg.entities[categoryname] == nil then
        arg.entities[categoryname] = {}
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
    if arg.entities[categoryname][locationName] == nil then
        arg.entities[categoryname][locationName] = {}
    end
    arg.entities[categoryname][locationName][#arg.entities[categoryname][locationName] + 1] = newEntity
end

local function registerProcessedEntity(arg, newEntity)
    if not IsSubEntity(newEntity) then
        addEntityToDict(arg, newEntity)
    end
    local label = GetProtectedStringField(newEntity, "label")
    labelToProcessedEntity[label] = newEntity
end

local function addFollowUpEntities(arg, newEntity)
    local mentionedEntities = GetMentionedEntities(newEntity)
    addPrimariesWhenMentioned(arg, mentionedEntities)
    for key, mentionedEntity in pairs(mentionedEntities) do
        if not IsEntityUnrevealed(mentionedEntity) then
            arg.mentioned[#arg.mentioned + 1] = mentionedEntity
        end
    end
end

local function processEntity(arg, entity)
    local newEntity = DeepCopy(entity)
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
