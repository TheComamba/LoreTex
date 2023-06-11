local ffi
local loreCore

local function getFFIModule()
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

local function getLib()
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

local function optionalEntityToString(inp)
    if IsEntity(inp) then
        local label = GetProtectedStringField(inp, "label")
        return [[ENTITY{]] .. label .. [[}]]
    else
        return ""
    end
end

local function shouldDescriptorBeWrittenToDatabase(descriptor)
    if descriptor == GetProtectedDescriptor("historyItems") then
        return false
    elseif descriptor == GetProtectedDescriptor("children") then
        return false
    else
        return true
    end
end

local function writeRelationshipToDatabase(dbPath, relationship)
    ffi = getFFIModule()
    loreCore = getLib()
    if not loreCore or not ffi then return nil end

    local result = loreCore.write_relationships(dbPath, relationship, 1)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

local function writeParentRelationshipsToDatabase(dbPath, childlabel, parentsAndRoles)
    ffi = getFFIModule()
    if not ffi then return nil end

    for key, parentAndRole in pairs(parentsAndRoles) do
        local parent = parentAndRole[1]
        local role = parentAndRole[2]
        local parentLabel = GetProtectedStringField(parent, "label")
        local relationship = ffi.new("CRelationship[1]")
        relationship[0].parent = parentLabel
        relationship[0].child = childlabel
        relationship[0].role = role
        writeRelationshipToDatabase(dbPath, relationship)
    end
end

local function createEntityColumn(label, descriptor, description)
    ffi = getFFIModule()
    if not ffi then return nil end

    local column = ffi.new("CEntityColumn[1]");

    column[0].label = label

    if not shouldDescriptorBeWrittenToDatabase(descriptor) then
        return nil
    elseif descriptor == GetProtectedDescriptor("parents") then
        return nil
    else
        column[0].descriptor = descriptor
    end

    if IsEntity(description) then
        column[0].description = optionalEntityToString(description)
    elseif type(description) == "table" then
        LogError([[Value to key \verb|]] .. descriptor .. [[| is a table.]])
        return nil
    else
        column[0].description = tostring(description)
    end

    return column
end

local function writeEntityColumnToDatabase(dbPath, column)
    ffi = getFFIModule()
    loreCore = getLib()
    if not loreCore or not ffi then return nil end

    if IsEmpty(column) then
        return
    end

    local result = loreCore.write_entity_columns(dbPath, column, 1)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

local function writeEntityToDatabase(dbPath, entity)
    local label = GetProtectedStringField(entity, "label")
    for descriptor, description in pairs(entity) do
        local column = createEntityColumn(label, descriptor, description)
        if column then
            if column[0].descriptor == GetProtectedDescriptor("parents") then
                writeParentRelationshipsToDatabase(dbPath, column[0].label, column[0].description)
            else
                writeEntityColumnToDatabase(dbPath, column)
            end
        else
        end
    end
end

local function getCHistoryItemsList()
    ffi = getFFIModule()
    if not ffi then return nil end

    local historyItems = ffi.new("CHistoryItem[" .. #AllHistoryItems .. "]")
    for i = 0, (#AllHistoryItems - 1) do
        local item = AllHistoryItems[i + 1]
        historyItems[i].label = GetProtectedStringField(item, "label")
        historyItems[i].content = GetProtectedStringField(item, "content")
        historyItems[i].is_concerns_others = GetProtectedNullableField(item, "isConcernsOthers")
        historyItems[i].is_secret = GetProtectedNullableField(item, "isSecret")
        historyItems[i].year = GetProtectedNullableField(item, "year")
        historyItems[i].day = GetProtectedNullableField(item, "day")
        local originator = GetProtectedNullableField(item, "originator")
        historyItems[i].originator = optionalEntityToString(originator)
        local yearFormat = GetProtectedNullableField(item, "yearFormat")
        historyItems[i].year_format = optionalEntityToString(yearFormat)
    end
    return historyItems, #AllHistoryItems
end

local function writeHistoryItemsToDatabase(dbPath)
    ffi = getFFIModule()
    loreCore = getLib()
    if not loreCore or not ffi then return nil end

    local items, len = getCHistoryItemsList()
    local result = loreCore.write_history_items(dbPath, items, len)

    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

TexApi.writeLoreToDatabase = function(dbPath)
    getLib() --Load the library if it hasn't been loaded yet.
    for key, entity in pairs(AllEntities) do
        writeEntityToDatabase(dbPath, entity)
    end
    writeHistoryItemsToDatabase(dbPath)
end
