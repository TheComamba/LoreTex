Append(ProtectedDescriptors, {"association"})
AssociationTypes = { "organisation", "family", "ship" }
AssociationTypeNames = { "Organisationen", "Familien", "Schiffe" }

function IsAssociation(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], AssociationTypes)
end

function AddAssociationDescriptors(entities)
    for key, entity in pairs(entities) do
        local associationList = {}
        if entity["association"] ~= nil then
            for key, associationAndRole in pairs(entity["association"]) do
                local associationLabel = associationAndRole[1]
                local assocationRole = associationAndRole[2]
                local association = GetEntity(associationLabel, AllEntities)
                if not IsEmpty(association) and IsShown(association) then
                    if IsEmpty(assocationRole) then
                        assocationRole = "Mitglied"
                    end
                    local description = assocationRole .. " der " .. TexCmd("nameref ", associationLabel) .. "."
                    if IsSecret(association) then
                        description = "(Geheim) " .. description
                    end
                    Append(associationList, description)
                end
            end
            SetDescriptor(entity, "Zusammenschlüsse", associationList)
        end
    end
end

function MarkSecret(entities)
    for key, entity in pairs(entities) do
        if IsEmpty(entity["name"]) then
            LogError("Entity at position " .. key .. " has no name!")
        elseif IsSecret(entity) then
            if entity["shortname"] == nil then
                entity["shortname"] = entity["name"]
            end
            entity["name"] = "(Geheim) " .. entity["name"]
        end
    end
end
