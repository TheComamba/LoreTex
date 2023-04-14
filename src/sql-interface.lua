local function getFFIModule()
    local ffi = require("ffi")
    if ffi == nil then
        LogError("Cannot load ffi module.")
        return nil
    end

    if ffi["load"] == nil then
        LogError [[
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

local function optionalEntityToString(inp)
    if IsEntity(inp) then
        local label = GetProtectedStringField(inp, "label")
        return [[ENTITY{]] .. label .. [[}]]
    else
        return ""
    end
end


local function writeEntityToDatabase(dbPath, entity)
    local rustLib, ffi = getLib()
    if not rustLib or not ffi then return nil end

    local label = GetProtectedStringField(entity, "label")
    for key, value in pairs(entity) do
        if key ~= GetProtectedDescriptor("historyItems") then
            if IsEntity(value) then
                value = optionalEntityToString(value)
            elseif type(value) == "table" then
                LogError([[Value to key \verb|]] .. key .. [[| is a table.]])
                value = DebugPrint(value)
            end

            local result = rustLib.write_entity_column(dbPath, label, key, tostring(value))
            local errorMessage = ffi.string(result)
            if errorMessage ~= "" then
                LogError(errorMessage)
            end
        end
    end
end

local function writeHistoryItemToDatabase(dbPath, item)
    local rustLib, ffi = getLib()
    if not rustLib or not ffi then return nil end

    local label = GetProtectedStringField(item, "label")
    local content = GetProtectedStringField(item, "content")
    local isConcernsOthers = GetProtectedNullableField(item, "isConcernsOthers")
    local isSecret = GetProtectedNullableField(item, "isSecret")
    local year = GetProtectedNullableField(item, "year")
    local day = GetProtectedNullableField(item, "day")
    -- if day == nil then day = 0 end
    local originator = GetProtectedNullableField(item, "originator")
    originator = optionalEntityToString(originator)
    local yearFormat = GetProtectedNullableField(item, "yearFormat")
    yearFormat = optionalEntityToString(yearFormat)

    local result = rustLib.write_history_item(dbPath, label, content, isConcernsOthers, isSecret, year, day, originator,
    yearFormat)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

TexApi.writeLoreToDatabase = function(dbPath)
    for key, entity in pairs(AllEntities) do
        writeEntityToDatabase(dbPath, entity)
    end
    for key, item in pairs(AllHistoryItems) do
        writeHistoryItemToDatabase(dbPath, item)
    end
end
