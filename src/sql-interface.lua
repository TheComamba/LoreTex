local loreCore, ffi

local function getFFIModule()
    local ffi = require("ffi")
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
    if loreCore then return loreCore, ffi end

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

    return loreCore, ffi
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
    loreCore, ffi = getLib()
    if not loreCore or not ffi then return nil end

    local result = loreCore.write_relationship(dbPath, relationship)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

local function writeParentRelationshipsToDatabase(dbPath, childlabel, parentsAndRoles)
    for key, parentAndRole in pairs(parentsAndRoles) do
        local parent = parentAndRole[1]
        local role = parentAndRole[2]
        local parentLabel = GetProtectedStringField(parent, "label")
        local relationship = {}
        relationship.parent = parentLabel
        relationship.child = childlabel
        relationship.role = role
        writeRelationshipToDatabase(dbPath, relationship)
    end
end

local function createEntityColumn(label, descriptor, description)
    local column = {};

    column.label = label

    if not shouldDescriptorBeWrittenToDatabase(descriptor) then
        return {}
    elseif descriptor == GetProtectedDescriptor("parents") then
        return {}
    else
        column.descriptor = descriptor
    end

    if IsEntity(description) then
        column.description = optionalEntityToString(description)
    elseif type(description) == "table" then
        LogError([[Value to key \verb|]] .. descriptor .. [[| is a table.]])
        return {}
    else
        column.description = tostring(description)
    end

    return column
end

local function writeEntityColumnToDatabase(dbPath, column)
    loreCore, ffi = getLib()
    if not loreCore or not ffi then return nil end

    if #column == 0 then
        return
    end

    local result = loreCore.write_entity_column(dbPath, column)
    local errorMessage = ffi.string(result)
    if errorMessage ~= "" then
        LogError(errorMessage)
    end
end

local function writeEntityToDatabase(dbPath, entity)
    local label = GetProtectedStringField(entity, "label")
    for descriptor, description in pairs(entity) do
        local column = createEntityColumn(label, descriptor, description)
        if column.descriptor == GetProtectedDescriptor("parents") then
            writeParentRelationshipsToDatabase(dbPath, column.label, column.description)
        else
            writeEntityColumnToDatabase(dbPath, column)
        end
    end
end

local function writeHistoryItemToDatabase(dbPath, item)
    loreCore, ffi = getLib()
    if not loreCore or not ffi then return nil end

    local item = {}
    item.label = GetProtectedStringField(item, "label")
    item.content = GetProtectedStringField(item, "content")
    item.isConcernsOthers = GetProtectedNullableField(item, "isConcernsOthers")
    item.isSecret = GetProtectedNullableField(item, "isSecret")
    item.year = GetProtectedNullableField(item, "year")
    item.day = GetProtectedNullableField(item, "day")
    local originator = GetProtectedNullableField(item, "originator")
    item.originator = optionalEntityToString(originator)
    local yearFormat = GetProtectedNullableField(item, "yearFormat")
    item.yearFormat = optionalEntityToString(yearFormat)

    local result = loreCore.write_history_item(dbPath, item)
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
