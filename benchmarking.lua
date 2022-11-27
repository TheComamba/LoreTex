local isBenchmarkingRun = false
local benchmarkingStartTimes = {}
local benchmarkingResults = {}

StateResetters[#StateResetters + 1] = function()
    isBenchmarkingRun = false
    benchmarkingStartTimes = {}
    benchmarkingResults = {}
end

local unbenchmarkables = {}
Append(unbenchmarkables, "ActivateBenchmarking")
Append(unbenchmarkables, "StartBenchmarking")
Append(unbenchmarkables, "StopBenchmarking")

function ActivateBenchmarking()
    isBenchmarkingRun = true
    for funName, fun in pairs(_G) do
        if type(fun) == "function" and not IsEmpty(funName) then
            if not IsIn(funName, unbenchmarkables) then
                _G[funName] = function(...)
                    StartBenchmarking(funName)
                    local out = { fun(...) }
                    StopBenchmarking(funName)
                    if #out == 0 then
                        return
                    elseif #out == 1 then
                        return out[1]
                    elseif #out == 2 then
                        return out[1], out[2]
                    elseif #out == 3 then
                        return out[1], out[2], out[3]
                    else
                        tex.print(funName .. " has more than 3 return values.")
                        return fun(...)
                    end
                end
            end
        end
    end
end

function IsBenchmarkingActivated()
    return isBenchmarkingRun
end

function StartBenchmarking(identifier)
    if not isBenchmarkingRun then
        return
    end
    if benchmarkingStartTimes[identifier] == nil then
        benchmarkingStartTimes[identifier] = {}
    end
    benchmarkingStartTimes[identifier][#benchmarkingStartTimes[identifier] + 1] = os.clock()
end

function StopBenchmarking(identifier)
    if not isBenchmarkingRun then
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
    if not isBenchmarkingRun then
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
