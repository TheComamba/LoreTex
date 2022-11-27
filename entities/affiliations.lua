local function addParentDescriptorsToChild(child)
    StartBenchmarking("AddParentDescriptorsToChild")
    local parentList = {}
    local parentsAndRelationships = GetProtectedTableField(child, "parents")
    Sort(parentsAndRelationships, "compareAffiliations")
    for key, parentAndRelationship in pairs(parentsAndRelationships) do
        local parent = parentAndRelationship[1]
        local relationship = parentAndRelationship[2]
        if GetProtectedDescriptor("location") ~= relationship then
            if IsEmpty(relationship) then
                relationship = CapFirst(Tr("member"))
            end
            if not IsEmpty(parent) and IsEntityShown(parent) then
                local parentLabel = GetProtectedStringField(parent, "label")
                local description = relationship ..
                    " " .. Tr("of") .. " " .. TexCmd("nameref ", parentLabel) .. "."
                if IsEntitySecret(parent) then
                    description = "(" .. CapFirst(Tr("secret")) .. ") " .. description
                end
                Append(parentList, description)
            end
        end
    end
    if not IsEmpty(parentList) then
        SetDescriptor { entity = child, descriptor = Tr("affiliations"), description = parentList }
    end
    StopBenchmarking("AddParentDescriptorsToChild")
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
            AddToProtectedField(parent, "mentions", childLocation)
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
    local childLabel = GetProtectedStringField(child, "label")
    Append(content, TexCmd("nameref", childLabel))
    Append(content, " ")
    Append(content, entityQualifiersString(child, parent, relationships))
    UniqueAppend(parent[descriptor], table.concat(content))
    AddToProtectedField(parent, "mentions", child)
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

function AddAffiliationDescriptors(entity)
    addParentDescriptorsToChild(entity)
    addChildrenDescriptorsToParent(entity)
end
