local planetRadiusInKM = 6371

local function distanceToHorizon(heightInM)
    local heightInKM = heightInM / 1000.
    local distanceFromCentre = planetRadiusInKM + heightInKM
    return math.sqrt(distanceFromCentre ^ 2 - planetRadiusInKM ^ 2)
end

function AddHeightDescriptor(entity)
    local heightInM = GetProtectedInheritableField(entity, "height")
    if heightInM == nil then
        return
    end
    local toHorizon = distanceToHorizon(heightInM)
    local toHorizonString = RoundedNumString(toHorizon, -1)
    local out = {}
    Append(out, heightInM)
    Append(out, "m (")
    Append(out, toHorizonString)
    Append(out, "km ")
    Append(out, Tr("visual-range-to-horizon"))
    Append(out, ").")
    local description = table.concat(out)
    SetDescriptor { entity = entity, descriptor = Tr("height"), description = description }
end
