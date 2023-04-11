local function getFFIModule()
    local ffi = require("ffi")
    if ffi == nil then
        LogError("Cannot load ffi module.")
        return nil
    end

    if ffi["load"] == nil then
        LogError[[
LuaLaTex has been called in restricted mode, which does not allow the loading of external libraries.
You need to call it with the \verb'--shell-escape' option.
See the installation section of README.md on how to do that.
]]
        return nil
    end

    return ffi
end

local function getCHeader()
    local headerPath = RelativePath .. [[../rust/loretex_api.h]]
    local file = io.open(headerPath, "r")
    if not file then
        LogError("Cannot load header file.")
        return nil
    end
    local content = file:read "*all"
    file:close()
    return content
end

local function getLib()
    local ffi = getFFIModule()
    if not ffi then return nil end

    local header = getCHeader()
    if not header then return nil end
    ffi.cdef(header)

    local libPath = RelativePath .. [[../rust/target/debug/libloretex.so]]
    local rustLib = ffi.load(libPath)
    if not rustLib then
        LogError("Cannot load rust library.")
        return nil
    end

    return rustLib, ffi
end


local function writeEntityToDatabase(entity)
    local rustLib, ffi = getLib()
    if not rustLib or not ffi then return nil end

    local dbPath = RelativePath .. [[../tmp_sql_example/example.db]]

    local label = GetProtectedStringField(entity, "label")
    for key, value in pairs(entity) do
        if IsEntity(value) then
            value = [[ENTITY{]] .. GetProtectedStringField(value, "label") .. [[}]]
        elseif type(value) == "table" then
            LogError([[Value to key \verb|]] .. key .. [[| is a table.]])
            value = DebugPrint(value)
        end
        local result = rustLib.write_database_column(dbPath, label, key, tostring(value))
        local errorMessage = ffi.string(result)
        if errorMessage ~= "" then
            LogError(errorMessage)
        end
    end
end

TexApi.writeLoreToDatabase = function(path)
    for key, entity in pairs(AllEntities) do
        writeEntityToDatabase(entity)
    end
end
