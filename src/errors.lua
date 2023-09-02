local errorMessages = {}
IsErrorsChronologicallySorted = false

function ResetErrors()
    errorMessages = {}
    IsErrorsChronologicallySorted = false
end

StateResetters[#StateResetters + 1] = ResetErrors

function LogError(errorMessage)
    if type(errorMessage) == "table" then
        local flatTable = {}
        for _, element in pairs(errorMessage) do
            Append(flatTable, element)
        end
        errorMessage = table.concat(flatTable)
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

function DebugPrintRaw(input)
    if type(input) ~= "table" then
        return { tostring(input) }
    end

    local out = {}

    local allKeys = GetSortedKeys(input)
    for _, key in pairs(allKeys) do
        local val = input[key]
        if IsEntity(val) then
            Append(out, tostring(key) .. " = [Entity " .. GetProtectedStringField(val, "label") .. "]")
        elseif type(val) == "table" then
            Append(out, tostring(key) .. ":")
            Append(out, [[{]])
            Append(out, DebugPrintRaw(val))
            Append(out, [[}]])
        else
            Append(out, tostring(key) .. " = " .. tostring(val))
        end
    end
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

function DebugPrint(input)
    local content = DebugPrintRaw(input)
    local out = {}
    Append(out, TexCmd("begin", "verbatim"))
    for _, line in pairs(content) do
        Append(out, SplitStringInLinebreaks(line, 100))
    end
    Append(out, TexCmd("end", "verbatim"))
    Append(out, TexCmd("vspace", "1cm"))
    return out
end
