local planetRadiusInKM = 6371

local function distanceToHorizon(heightInM)
    local heightInKM = heightInM / 1000.
    local distanceFromCentre = planetRadiusInKM + heightInKM
    return math.sqrt(distanceFromCentre ^ 2 - planetRadiusInKM ^ 2)
end

function AddHeightDescriptor(entity)
    local heightInM = GetProtectedNullableField(entity, "height", false)
    if heightInM == nil then
        return
    end
    local toHorizon = distanceToHorizon(heightInM)
    local decimals = -math.floor(math.log(toHorizon / 10, 10))
    local toHorizonString = RoundedNumString(toHorizon, decimals)
    local out = {}
    Append(out, heightInM)
    Append(out, "m (")
    Append(out, toHorizonString)
    Append(out, "km ")
    Append(out, Tr("visual_range_to_horizon"))
    Append(out, ").")
    local description = table.concat(out)
    SetDescriptor { entity = entity, descriptor = Tr("height"), description = description }
end
