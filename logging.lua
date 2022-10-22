IsThrowOnError = false
local errorMessages = {}
local benchmarkingStartTimes = {}
local benchmarkingResults = {}

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
    table.sort(errorMessages, StrCmp)
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
        Append(out, TexCmd("section", "Errors"))
        Append(out, TexCmd("RpgTex"))
        Append(out, " encountered " .. #errorMessages .. " errors:")
        Append(out, ListAll(cleanedErrors()))
        Append(out, "For a traceback, use the ThrowOnError command, rerun, and search the logfile for \"traceback\".")
        Append(out, TexCmd("newpage"))
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
    table.sort(out, StrCmp)
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

function StartBenchmarking(identifier)
    if benchmarkingStartTimes[identifier] ~= nil then
        local mess = {}
        Append(mess, "Benchmarking for identifier \"")
        Append(mess, identifier)
        Append(mess, "\" has already begun. ")
        Append(mess, "Benchmarking is not implemented for recursive functions!")
        LogError(mess)
        return
    end
    benchmarkingStartTimes[identifier] = os.clock()
end

function StopBenchmarking(identifier)
    if benchmarkingStartTimes[identifier] == nil then
        local mess = {}
        Append(mess, "Benchmarking for identifier \"")
        Append(mess, identifier)
        Append(mess, "\" has never been started.")
        LogError(mess)
        return
    end
    local time = os.clock() - benchmarkingStartTimes[identifier]
    benchmarkingStartTimes[identifier] = nil
    if benchmarkingResults[identifier] == nil then
        benchmarkingResults[identifier] = {}
        benchmarkingResults[identifier]["calls"] = 0
        benchmarkingResults[identifier]["time"] = 0
    end
    benchmarkingResults[identifier]["calls"] = benchmarkingResults[identifier]["calls"] + 1
    benchmarkingResults[identifier]["time"] = benchmarkingResults[identifier]["time"] + time
end

function PrintBenchmarking()
    local benchmarkStrings = {}
    for identifier, timeAndCalls in pairs(benchmarkingResults) do
        local time = timeAndCalls["time"]
        local calls = timeAndCalls["calls"]
        local str = {}
        Append(str, identifier)
        Append(str, ": ")
        Append(str, RoundedNumString(time, 1))
        Append(str, "s, called ")
        if calls == 1 then
            Append(str, "once")
        else
            Append(str, calls)
            Append(str, " times (")
            Append(str, RoundedNumString(time / calls, 3))
            Append(str, "s on avg.)")
        end
        benchmarkStrings[#benchmarkStrings + 1] = { time, table.concat(str) }
    end
    local out = {}
    if not IsEmpty(benchmarkStrings) then
        table.sort(benchmarkStrings, function(a, b) return a[1] > b[1] end)
        Append(out, TexCmd("section", "Benchmarking"))
        Append(out, TexCmd("RpgTex"))
        Append(out, " benchmarked the following functions (sorted by total runtime):")
        Append(out, TexCmd("begin", "itemize"))
        for key, timeAndString in pairs(benchmarkStrings) do
            Append(out, TexCmd("item"))
            Append(out, timeAndString[2])
        end
        Append(out, TexCmd("end", "itemize"))
    end
    return out
end
