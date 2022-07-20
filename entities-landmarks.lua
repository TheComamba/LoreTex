LandmarkTypes = { "forest", "grassland", "range", "mountain", "river", "glacier", "lake" }
LandmarkTypeNames = { "Wälder", "Grasländer", "Gebirge", "Berge", "Flüsse", "Gletscher", "Seen" }

function IsLandmark(entity)
    if entity == nil then
        return false
    end
    local type = entity["type"]
    return type ~= nil and IsIn(entity["type"], LandmarkTypes)
end
