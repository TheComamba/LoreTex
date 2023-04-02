
local function writeEntityToDatabase(entity)
    LogError("writeEntityToDatabase is not yet implemented.")
end

TexApi.writeLoreToDatabase = function(path)
    for key, entity in pairs(AllEntities) do
        writeEntityToDatabase(entity)
    end
end
