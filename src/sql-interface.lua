
local function writeEntityToDatabase(entity)
    local ffi = require("ffi")
    if ffi == nil then
        LogError("Cannot load ffi module.")
        return
    end

    local rust_lib = ffi.load("./rust/target/debug/liblore_tex.so")
    if rust_lib == nil then
        LogError("Cannot load rust library.")
        return
    end

    ffi.cdef[[
        int test();
    ]]

    testresult = rust_lib.test()
    tex.print(testresult)
    LogError("writeEntityToDatabase is not yet implemented.")
end

TexApi.writeLoreToDatabase = function(path)
    for key, entity in pairs(AllEntities) do
        writeEntityToDatabase(entity)
    end
end
