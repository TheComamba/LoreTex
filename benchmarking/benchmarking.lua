local isBenchmarkingRun = false
local benchmarkingResults = {}

StateResetters[#StateResetters + 1] = function()
    isBenchmarkingRun = false
    benchmarkingResults = {}
end

local function benchmark(funName, fun, ...)
    local before = os.clock()
    local out = { fun(...) }
    local time = os.clock() - before
    benchmarkingResults[funName]["calls"] = benchmarkingResults[funName]["calls"] + 1
    benchmarkingResults[funName]["time"] = benchmarkingResults[funName]["time"] + time
    return table.unpack(out)
end

function ActivateBenchmarking()
    isBenchmarkingRun = true
    for key, funTable in pairs({ _G, TexApi, Comparer }) do
        for funName, fun in pairs(funTable) do
            if type(fun) == "function" then
                funTable[funName] = function(...)
                    return benchmark(funName, fun, ...)
                end
                if benchmarkingResults[funName] ~= nil then
                    LogError("Function with name " .. funName .. " defined more than once!")
                end
                benchmarkingResults[funName] = {}
                benchmarkingResults[funName]["calls"] = 0
                benchmarkingResults[funName]["time"] = 0
            end
        end
    end
end

function IsBenchmarkingActivated()
    return isBenchmarkingRun
end

local function getBenchmarkStrings()
    local out = {}
    for identifier, timeAndCalls in pairs(benchmarkingResults) do
        local time = timeAndCalls["time"]
        local calls = timeAndCalls["calls"]
        if calls > 0 then
            local str = {}
            identifier = Replace("_", [[\_]], identifier)
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
    if #benchmarkStrings > 0 then
        table.sort(benchmarkStrings, function(a, b) return a[1] > b[1] end)
        Append(out, TexCmd("chapter", "Benchmarking"))
        Append(out, TexCmd("LoreTex"))
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

local size = 1
function SetBenchmarkingSize(num)
    local numcast = tonumber(num)
    if numcast == nil then
        LogError("Called with " .. DebugPrint(num))
    else
        size = numcast
    end
end

function CreateBenchmarkingTest(sizeStr)
    local numcast = tonumber(sizeStr)
    if numcast == nil then
        LogError("Called with " .. DebugPrint(sizeStr))
    else
        size = numcast
    end
    TexApi.setCurrentYear(1400)
    for i = size, 1, -1 do
        TexApi.newEntity { type = "places", label = "place-" .. i, name = "Place " .. i }
        TexApi.addHistory { year = -i,
            event = [[Birth of \reference{char-]] .. i .. [[-1} \birthof{char-]] .. i .. [[-1}]] }
        TexApi.makeEntityPrimary("place-" .. i)

        TexApi.newEntity { type = "species", label = "species-" .. i, name = "Species " .. i }
        TexApi.setAgeFactor(i)
        TexApi.makeEntityPrimary("species-" .. i)

        TexApi.newEntity { type = "other", label = "organisation-" .. i, name = "Organisation " .. i }
        TexApi.makeEntityPrimary("organisation-" .. i)
        if i > 1 then
            TexApi.setLocation("place-" .. (i - 1))
        end

        for j = 10, 1, -1 do
            local label = "char-" .. i .. "-" .. j
            TexApi.newCharacter { label = label, name = label }
            TexApi.setSpecies("species-" .. i)
            TexApi.setLocation("place-" .. i)
            TexApi.addParent { parentLabel = "organisation-" .. i }
            TexApi.setDescriptor { descriptor = "Best Friend", description = [[\nameref{mentioned-char-]] .. i .. [[}]] }
            TexApi.makeEntityPrimary(label)
        end

        TexApi.newCharacter { label = "mentioned-char-" .. i, name = "Mentioned Character " .. i }
    end

    local out = TexApi.automatedChapters()
    return out
end
