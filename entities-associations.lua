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
    local associationsAndRoles = entity["associations"]
    if associationsAndRoles ~= nil then
        if type(associationsAndRoles) == "string" then
            associationsAndRoles = { associationsAndRoles }
        end
        for key, associationAndRole in pairs(associationsAndRoles) do
            if type(associationAndRole) == "string" then
                associationAndRole = { associationAndRole }
            end
            local associationLabel = associationAndRole[1]
            local assocationRole = associationAndRole[2]
            local association = GetEntity(associationLabel)
            if not IsEmpty(association) and IsEntityShown(association) then
                if IsEmpty(assocationRole) then
                    assocationRole = CapFirst(Tr("member"))
                end
                local description = assocationRole ..
                    " " .. Tr("of") .. " " .. TexCmd("nameref ", associationLabel) .. "."
                if IsEntitySecret(association) then
                    description = "(" .. CapFirst(Tr("secret")) .. ") " .. description
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
    elseif IsEntitySecret(entity) then
        if entity["shortname"] == nil then
            entity["shortname"] = entity["name"]
        end
        entity["name"] = "(" .. CapFirst(Tr("secret")) .. ") " .. entity["name"]
    end
end
