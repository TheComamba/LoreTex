Append(ProtectedDescriptors, { "associations" })
AssociationTypes = { "organisations", "families", "ships" }
AssociationTypeNames = { "Organisationen", "Familien", "Schiffe" }

function IsAssociation(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], AssociationTypes)
end

function AddAssociationDescriptors(entity)
    local associationList = {}
    if entity["associations"] ~= nil then
        for key, associationAndRole in pairs(entity["associations"]) do
            local associationLabel = associationAndRole[1]
            local assocationRole = associationAndRole[2]
            local association = GetEntity(associationLabel)
            if not IsEmpty(association) and IsShown(association) then
                if IsEmpty(assocationRole) then
                    assocationRole = CapFirst(Tr("member"))
                end
                local description = assocationRole ..
                    " " .. Tr("of") .. " " .. TexCmd("nameref ", associationLabel) .. "."
                if IsSecret(association) then
                    description = "(" .. Tr("secret") .. ") " .. description
                end
                Append(associationList, description)
            end
        end
        SetDescriptor(entity, CapFirst(Tr("associations")), associationList)
    end
end

function MarkSecret(entity)
    if IsEmpty(entity["name"]) then
        LogError("Entity has no name: " .. DebugPrint(entity))
    elseif IsSecret(entity) then
        if entity["shortname"] == nil then
            entity["shortname"] = entity["name"]
        end
        entity["name"] = "(" .. CapFirst(Tr("secret")) .. ") " .. entity["name"]
    end
end
