AssociationTypes = { "organisation", "family", "ship" }
AssociationTypeNames = { "Organisationen", "Familien", "Schiffe" }

function IsAssociation(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], AssociationTypes)
end

function AddAssociationDescriptors()
    for label, entity in pairs(Entities) do
        local associationLabel = entity["association"]
        local assocationRole = entity["association-role"]
        if not IsEmpty(associationLabel) then
            if not IsSecret(associationLabel) or ShowSecrets then
                if IsEmpty(assocationRole) then
                    assocationRole = "Mitglied"
                end
                local description = assocationRole .. " der " .. TexCmd("myref ", associationLabel) .. "."
                SetDescriptor(label, "Zusammenschluss", description)
            end
        end
    end
end
