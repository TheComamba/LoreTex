local ffi
local loreCore

function getFFIModule()
    if ffi then return ffi end

    ffi = require("ffi")
    if ffi == nil then
        LogError("Cannot load ffi module.")
        return nil
    end

    if ffi["load"] == nil then
        LogError [[
LuaLaTex cannot access the ffi (foreign function interface) library.
This is most likely because it has been called in restricted mode, which does not allow the loading of external libraries.
You need to call it with the \verb'--shell-escape' option.
See the installation section of README.md on how to do that.
]]
        return nil
    end

    return ffi
end

local function getCHeader()
    local headerPath = RelativePath .. [[../dependencies/lorecore_api.h]]
    local file = io.open(headerPath, "r")
    if not file then
        LogError("Cannot load header file at " .. headerPath .. ".")
        return nil
    end
    local content = file:read "*all"
    file:close()
    return content
end

function getLib()
    if loreCore then return loreCore end

    ffi = getFFIModule()
    if not ffi then return nil end

    local header = getCHeader()
    if not header then return nil end
    ffi.cdef(header)

    local libPath = RelativePath .. [[../dependencies/liblorecore.so]]
    loreCore = ffi.load(libPath)
    if not loreCore then
        LogError("Cannot load rust library.")
        return nil
    end

    return loreCore
end
