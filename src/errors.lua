local errorMessages = {}
IsErrorsChronologicallySorted = false

function ResetErrors()
    errorMessages = {}
    IsErrorsChronologicallySorted = false
end

StateResetters[#StateResetters + 1] = ResetErrors

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
        errorMessage = "In function \"" .. caller .. "\": " .. errorMessage
    end
    if IsErrorsChronologicallySorted then
        errorMessage = tostring(#errorMessages + 1) .. ".: " .. errorMessage
    end
    if IsThrowOnError then
        error(errorMessage)
    else
        errorMessages[#errorMessages + 1] = string.gsub(errorMessage, [[_]], [[\_]])
    end
end

function HasError()
    return #errorMessages > 0
end

local function cleanedErrors()
    Sort(errorMessages, "compareString")
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
    if #errorMessages > 0 then
        Append(out, TexCmd("section", "Errors"))
        Append(out, TexCmd("LoreTex"))
        Append(out, " encountered " .. #errorMessages .. " errors:")
        Append(out, ListAll(cleanedErrors()))
        Append(out, "For a traceback, use the ThrowOnError command, rerun, and search the logfile for \"traceback\".")
        Append(out, TexCmd("newpage"))
    end
    return out
end

function DebugPrintRaw(entity)
    if entity == nil then
        return { "nil" }
    elseif type(entity) == "number" then
        return { tostring(entity) }
    elseif type(entity) == "string" then
        return { " \"" .. entity .. "\" " }
    elseif type(entity) ~= "table" then
        return { tostring(entity) }
    end
    local out = {}
    local keys = GetSortedKeys(entity)
    Append(out, [[{	]])
    for i, key in pairs(keys) do
        if i > 1 then
            Append(out, ",	")
        end
        Append(out, DebugPrintRaw(key))
        Append(out, "=")
        if IsEntity(entity[key]) then
            local label = GetProtectedStringField(entity[key], "label")
            Append(out, "[Entity \"" .. label .. "\"]")
        else
            Append(out, DebugPrintRaw(entity[key]))
        end
    end
    Append(out, [[}	]])
    return out
end

function SplitStringInLinebreaks(str, maxWidth)
    if not str then return { "nil" } end
    local out = {}
    while string.len(str) > 0 do
        Append(out, string.sub(str, 1, maxWidth))
        str = string.sub(str, maxWidth + 1)
    end
    return out
end

function DebugPrint(entity)
    local content = DebugPrintRaw(entity)
    local splitContent = SplitStringInLinebreaks(table.concat(content), 100)
    local out = {}
    Append(out, TexCmd("begin", "verbatim"))
    Append(out, splitContent)
    Append(out, TexCmd("end", "verbatim"))
    return out
end
