
local function writeEntityToDatabase(entity)
    local luasql = require "luasql.sqlite3"
    local sqlite = luasql.sqlite3()
    if sqlite == nil then
        LogError("Sqlite module could not be loaded.")
        return
    end
end

TexApi.writeLoreToDatabase = function(path)
    for key, entity in pairs(AllEntities) do
        writeEntityToDatabase(entity)
    end
end
