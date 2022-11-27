local benchmarkingStartTimes = {}
local benchmarkingResults = {}

StateResetters[#StateResetters + 1] = function()
    benchmarkingStartTimes = {}
    benchmarkingResults = {}
end

function StartBenchmarking(identifier)
    if not IsBenchmarkingRun then
        return
    end
    if benchmarkingStartTimes[identifier] == nil then
        benchmarkingStartTimes[identifier] = {}
    end
    benchmarkingStartTimes[identifier][#benchmarkingStartTimes[identifier] + 1] = os.clock()
end

function StopBenchmarking(identifier)
    if not IsBenchmarkingRun then
        return
    end
    if benchmarkingStartTimes[identifier] == nil or #benchmarkingStartTimes[identifier] == 0 then
        local mess = {}
        Append(mess, "Benchmarking for identifier \"")
        Append(mess, identifier)
        Append(mess, "\" has not been started.")
        LogError(mess)
        return
    end
    local time = os.clock() - benchmarkingStartTimes[identifier][#benchmarkingStartTimes[identifier]]
    benchmarkingStartTimes[identifier][#benchmarkingStartTimes[identifier]] = nil
    if benchmarkingResults[identifier] == nil then
        benchmarkingResults[identifier] = {}
        benchmarkingResults[identifier]["calls"] = 0
        benchmarkingResults[identifier]["time"] = 0
    end
    benchmarkingResults[identifier]["calls"] = benchmarkingResults[identifier]["calls"] + 1
    benchmarkingResults[identifier]["time"] = benchmarkingResults[identifier]["time"] + time
end

local function getBenchmarkStrings()
    local out = {}
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
        out[#out + 1] = { time, table.concat(str) }
    end
    return out
end

function PrintBenchmarking()
    if not IsBenchmarkingRun then
        local message = "PrintBenchmarking called, but benchmarking has not been activated!"
        LogError(message)
        return { message }
    end
    local benchmarkStrings = getBenchmarkStrings()
    local out = {}
    if not IsEmpty(benchmarkStrings) then
        table.sort(benchmarkStrings, function(a, b) return a[1] > b[1] end)
        Append(out, TexCmd("chapter", "Benchmarking"))
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
