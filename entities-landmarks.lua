HeightCaption = "Höhe"
LandmarkTypes = { "forests", "grasslands", "mountainranges", "mountains", "rivers", "glaciers", "lakes" }
LandmarkTypeNames = { "Wälder", "Grasländer", "Gebirge", "Berge", "Flüsse", "Gletscher", "Seen" }
local planetRadiusInKM = 6371

function IsLandmark(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], LandmarkTypes)
end

local function distanceToHorizon(heightInM)
    local heightInKM = heightInM / 1000.
    local distanceFromCentre = planetRadiusInKM + heightInKM
    return math.sqrt(distanceFromCentre ^ 2 - planetRadiusInKM ^ 2)
end

function HeightDescriptor(inputInM)
    local heightInM = tonumber(inputInM)
    if heightInM == nil then
        LogError("Called with " .. DebugPrint(inputInM))
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
    return out
end
