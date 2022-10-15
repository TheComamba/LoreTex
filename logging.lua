IsThrowOnError = false
local errorMessages = {}

function LogError(errorMessage)
    if type(errorMessage) == "table" then
        errorMessage = table.concat(errorMessage)
    end
    errorMessage = tostring(errorMessage)
    if errorMessage == nil or type(errorMessage) ~= "string" then
        LogError("Something went seriously wrong!")
        return
    end
    local caller = debug.getinfo(2).name
    if caller ~= nil and type(caller) == "string" then
        caller = string.gsub(caller, [[_]], [[\_]])
        errorMessage = "In function \"" .. caller .. "\": " .. errorMessage
    end
    if IsThrowOnError then
        error(errorMessage)
    else
        errorMessages[#errorMessages + 1] = errorMessage
    end
end

function HasError()
    return #errorMessages > 0
end

function ResetErrors()
    errorMessages = {}
end

local function cleanedErrors()
    table.sort(errorMessages)
    local out = {}
    local count = 1
    for i, mess in pairs(errorMessages) do
        if mess ~= errorMessages[i + 1] then
            local str = mess
            if count > 1 then
                str = str .. " (encountered " .. count .. " times)"
            end
            out[#out + 1] = str
            count = 1
        else
            count = count + 1
        end
    end
    return out
end

function PrintErrors()
    local out = {}
    if not IsEmpty(errorMessages) then
        Append(out, TexCmd("RpgTex"))
        Append(out, " encountered " .. #errorMessages .. " errors:")
        Append(out, ListAll(cleanedErrors()))
        Append(out, "For a traceback, use the \\ThrowOnError command, rerun, and search the logfile for \"traceback\".")
    end
    return out
end

local function getKeysOfType(tableInput, keyType)
    local out = {}
    for key, elem in pairs(tableInput) do
        if type(key) == keyType then
            Append(out, key)
        end
    end
    table.sort(out)
    return out
end

local function getSortedKeys(tableInput)
    local out = {}
    Append(out, getKeysOfType(tableInput, "number"))
    Append(out, getKeysOfType(tableInput, "string"))
    return out
end

local function debugPrintRaw(entity)
    if entity == nil then
        return "nil"
    elseif type(entity) == "number" then
        return tostring(entity)
    elseif type(entity) == "string" then
        return " \"" .. entity .. "\" "
    elseif type(entity) ~= "table" then
        return tostring(entity)
    end
    local out = {}
    local keys = getSortedKeys(entity)
    Append(out, [[{	]])
    for i, key in pairs(keys) do
        if i > 1 then
            Append(out, ",	")
        end
        Append(out, debugPrintRaw(key))
        Append(out, "=")
        Append(out, debugPrintRaw(entity[key]))
    end
    Append(out, [[}	]])
    return table.concat(out)
end

function DebugPrint(entity)
    local out = {}
    Append(out, TexCmd("begin", "verbatim"))
    Append(out, debugPrintRaw(entity))
    Append(out, TexCmd("end", "verbatim"))
    return table.concat(out)
end
