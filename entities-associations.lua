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
        if IsShown(associationLabel) then
            if IsEmpty(assocationRole) then
                assocationRole = "Mitglied"
            end
            local description = assocationRole .. " der " .. TexCmd("myref ", associationLabel) .. "."
            if IsSecret(associationLabel) then
                description = "(Geheim) " .. description
            end
            SetDescriptor(label, "Zusammenschluss", description)
        end
    end
end

function MarkSecret()
    for key, entity in pairs(Entities) do
        if IsSecret(entity) then
            if entity["shortname"] == nil then
                entity["shortname"] = entity["name"]
            end
            entity["name"] = "(Geheim) " .. entity["name"]
        end
    end
end
