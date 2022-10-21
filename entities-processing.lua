local function entityQualifiersString(srcEntity, targetEntity, role)
    local content = {}
    if IsEntitySecret(srcEntity) then
        Append(content, Tr("secret"))
    end
    if not IsEmpty(role) then
        Append(content, role)
    end
    local birthyearstr = srcEntity["born"]
    local birthyear = tonumber(birthyearstr)
    if not IsEmpty(birthyear) and birthyear <= CurrentYearVin then
        birthyear = ConvertYearFromVin(birthyear, YearFmt)
        Append(content, TexCmd("textborn") .. birthyear)
    end
    local deathyearstr = srcEntity["died"]
    local deathyear = tonumber(deathyearstr)
    if not IsEmpty(deathyear) and deathyear <= CurrentYearVin then
        deathyear = ConvertYearFromVin(deathyear, YearFmt)
        Append(content, TexCmd("textdied") .. deathyear)
    end
    local location = srcEntity["location"]
    local targetLocation = targetEntity["location"]
    if IsLocationUnrevealed(srcEntity) then
        Append(content, Tr("at-secret-location"))
    elseif not IsPlace(targetEntity) and not IsEmpty(location) and location ~= targetLocation then
        Append(content, Tr("in") .. " " .. TexCmd("nameref", location))
    end
    if not IsEmpty(content) then
        return "(" .. table.concat(content, ", ") .. ")"
    else
        return ""
    end
end

local function addSingleEntity(srcEntity, targetEntity, entityType, role)
    local name = Tr(entityType)
    if targetEntity[name] == nil then
        targetEntity[name] = {}
    end
    local content = {}
    local srcLabel = GetMainLabel(srcEntity)
    Append(content, TexCmd("nameref", srcLabel))
    Append(content, " ")
    Append(content, entityQualifiersString(srcEntity, targetEntity, role))
    UniqueAppend(targetEntity[name], table.concat(content))
end

local function addEntitiesTo(entityType, keyword, entities)
    local srcEntities = GetEntitiesOfType(entityType)
    srcEntities = GetEntitiesIf(IsEntityShown, srcEntities)
    for label, srcEntity in pairs(srcEntities) do
        local targets = srcEntity[keyword]
        if targets ~= nil then
            if type(targets) ~= "table" then
                targets = { targets }
            end
            for key, target in pairs(targets) do
                local targetLabel = ""
                local role = ""
                if type(target) == "string" then
                    targetLabel = target
                elseif type(target) == "table" then
                    targetLabel = target[1]
                    role = target[2]
                end
                local targetEntity = GetMutableEntity(targetLabel, entities)
                if targetEntity ~= nil then
                    addSingleEntity(srcEntity, targetEntity, entityType, role)
                end
            end
        end
    end
end

local function addAllEntitiesTo(entities)
    for type, name in pairs(TypeToNameMap()) do
        for key2, keyword in pairs({ "location", "associations" }) do
            addEntitiesTo(type, keyword, entities)
        end
    end
end

function AddAutomatedDescriptors(entities)
    addAllEntitiesTo(entities)
    ProcessHistory(entities)
    for key, entity in pairs(entities) do
        AddAssociationDescriptors(entity)
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
        MarkDead(entity)
        MarkSecret(entity)
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
    ScanContentForSecondaryRefs(entitiesOut)
    StopBenchmarking("ProcessEntities")
    return entitiesOut
end
