local function getFFIModule()
    local ffi = require("ffi")
    if ffi == nil then
        LogError("Cannot load ffi module.")
        return nil
    end

    if ffi["load"] == nil then
        LogError[[
LuaLaTex has been called in restricted mode, which does not allow the loading of external libraries.

If you're running from a terminal, call the \verb'lualatex' command with the \verb'--enable-write18' option.
]]
        return nil
    end

    return ffi
end

local function getCHeader()
    local headerPath = RelativePath .. [[../rust/loretex_api.h]]
    local file = io.open(headerPath, "r")
    if not file then
        LogError("Cann load header file.")
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

    return rustLib
end


local function writeEntityToDatabase(entity)
    local rustLib = getLib()
    if not rustLib then return nil end

    local dbPath = RelativePath .. [[../rust/example.db]]

    result = rustLib.write_database_column(dbPath, "finny", "ninny", "willigreg")
    if result ~= 0 then
        LogError("Something went wrong during writeEntityToDatabase. No idea what, though.")
        return
    end
end

TexApi.writeLoreToDatabase = function(path)
    for key, entity in pairs(AllEntities) do
        writeEntityToDatabase(entity)
    end
end
