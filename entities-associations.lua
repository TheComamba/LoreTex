AssociationTypes = { "organisations", "families", "ships" }
AssociationTypeNames = { "Organisationen", "Familien", "Schiffe" }

function IsAssociation(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], AssociationTypes)
end

function AddParentDescriptorsToChildren(entity)
    local parentList = {}
    local parentsAndRelationships = entity["parents"]
    if parentsAndRelationships ~= nil then
        if type(parentsAndRelationships) == "string" then
            parentsAndRelationships = { parentsAndRelationships }
        end
        for key, parentAndRelationship in pairs(parentsAndRelationships) do
            if type(parentAndRelationship) == "string" then
                parentAndRelationship = { parentAndRelationship }
            end
            local parentLabel = parentAndRelationship[1]
            local relationship = parentAndRelationship[2]
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
        SetDescriptor(entity, Tr("affiliations"), parentList)
    end
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
