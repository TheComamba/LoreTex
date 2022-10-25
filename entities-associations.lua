local function compareByNameOfFirstElement(a, b)
    return CompareByName(a[1], b[1])
end

function AddParentDescriptorsToChild(child)
    StartBenchmarking("AddParentDescriptorsToChild")
    local parentList = {}
    local parentsAndRelationships = child["parents"]
    if parentsAndRelationships ~= nil then
        if type(parentsAndRelationships) == "string" then
            parentsAndRelationships = { parentsAndRelationships }
        end
        table.sort(parentsAndRelationships, compareByNameOfFirstElement)
        for key, parentAndRelationship in pairs(parentsAndRelationships) do
            if type(parentAndRelationship) == "string" then
                parentAndRelationship = { parentAndRelationship }
            end
            local parentLabel = parentAndRelationship[1]
            local relationship = parentAndRelationship[2]
            if parentLabel ~= child["location"] or not IsEmpty(relationship) then
                local parent = GetEntity(parentLabel)
                if not IsEmpty(parent) and IsEntityShown(parent) then
                    if IsEmpty(relationship) then
                        relationship = CapFirst(Tr("member"))
                    end
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
            SetDescriptor(child, Tr("affiliations"), parentList)
        end
    end
    StopBenchmarking("AddParentDescriptorsToChild")
end

function MarkSecret(entity)
    if IsEmpty(entity["name"]) then
        LogError("Entity has no name: " .. DebugPrint(entity))
    elseif IsEntitySecret(entity) then
        if entity["shortname"] == nil then
            entity["shortname"] = entity["name"]
        end
        entity["name"] = "(" .. CapFirst(Tr("secret")) .. ") " .. entity["name"]
    end
end
