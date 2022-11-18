function AddParentDescriptorsToChild(child)
    StartBenchmarking("AddParentDescriptorsToChild")
    local parentList = {}
    local parentsAndRelationships = GetProtectedField(child, "parents")
    if parentsAndRelationships ~= nil then
        if type(parentsAndRelationships) == "string" then
            parentsAndRelationships = { parentsAndRelationships }
        end
        table.sort(parentsAndRelationships, CompareAffiliations)
        for key, parentAndRelationship in pairs(parentsAndRelationships) do
            if type(parentAndRelationship) == "string" then
                parentAndRelationship = { parentAndRelationship }
            end
            local parent = parentAndRelationship[1]
            local relationship = parentAndRelationship[2]
            if GetProtectedDescriptor("location") ~= relationship then
                if IsEmpty(relationship) then
                    relationship = CapFirst(Tr("member"))
                    if not IsEmpty(parent) and IsEntityShown(parent) then
                    end
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
    end
    StopBenchmarking("AddParentDescriptorsToChild")
end

function MarkSecret(entity)
    local name = GetProtectedField(entity, "name")
    if IsEmpty(name) then
        LogError("Entity has no name: " .. DebugPrint(entity))
    elseif IsEntitySecret(entity) then
        if IsEmpty(GetProtectedField(entity, "shortname")) then
            SetProtectedField(entity, "shortname", name)
        end
        SetProtectedField(entity, "name", "(" .. CapFirst(Tr("secret")) .. ") " .. name)
    end
end
