
local function writeEntityToDatabase(entity)
    local ffi = require("ffi")
    if ffi == nil then
        LogError("Cannot load ffi module.")
        return
    end

    if ffi["load"] == nil then
        LogError[[
LuaLaTex has been called in restricted mode, which does not allow the loading of external libraries.

If you're running from a terminal, call the \verb'lualatex' command with the \verb'--enable-write18' option.
]]
        return
    end

    local libPath = RelativePath .. [[../rust/target/debug/libloretex.so]]
    local rustLib = ffi.load(libPath)
    if rustLib == nil then
        LogError("Cannot load rust library.")
        return
    end

    ffi.cdef[[
        int test();
    ]]

    testresult = rustLib.test()
    tex.print(testresult)
    LogError("writeEntityToDatabase is not yet implemented.")
end

TexApi.writeLoreToDatabase = function(path)
    for key, entity in pairs(AllEntities) do
        writeEntityToDatabase(entity)
    end
end
