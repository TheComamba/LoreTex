function AddParentDescriptorsToChild(child)
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
                local parentLabel = GetMainLabel(parent)
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

function MarkSecret(entity)
    local name = GetProtectedStringField(entity, "name")
    if IsEmpty(name) then
        LogError("Entity has no name: " .. DebugPrint(entity))
    elseif IsEntitySecret(entity) then
        if IsEmpty(GetProtectedStringField(entity, "shortname")) then
            SetProtectedField(entity, "shortname", name)
        end
        SetProtectedField(entity, "name", "(" .. CapFirst(Tr("secret")) .. ") " .. name)
    end
end
