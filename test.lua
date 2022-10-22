local allTestFiles = { "common", "default-location", "dictionary", "entities-with-associations", "entities-with-history",
    "entity-visibility", "history", "make-primary-if", "mentioned-refs", "npc-and-species", "primary-when-mentioned-type",
    "refs", "region-and-city", "sub-label" }
local numSucceeded = 0
local numFailed = 0

local function resetEnvironment()
    ResetEntities()
    ResetRefs()
    Histories = {}
    CurrentYearVin = 0
    PrintHistoryYear = 0
    PrintHistoryDay = 0
    DefaultLocation = ""
    IsShowFuture = true
    IsShowSecrets = false
end

local function areEqual(obj1, obj2, elementNum, currentObj1, currentObj2)
    if obj1 == nil or obj2 == nil then
        if obj1 == nil and obj2 == nil then
            return true
        else
            return false
        end
    elseif type(obj1) ~= type(obj2) then
        return false
    elseif type(obj1) == "table" then
        if #obj1 ~= #obj2 then
            elementNum[1] = -1
            currentObj1[1] = #obj1
            currentObj2[1] = #obj2
            return false
        end
        for i = 1, #obj1 do
            if not areEqual(obj1[i], obj2[i], elementNum, currentObj1, currentObj2) then
                elementNum[1] = i
                currentObj1[1] = obj1[i]
                currentObj2[1] = obj2[i]
                return false
            end
        end
        return true
    else
        obj1 = Replace(" ", "", obj1)
        obj2 = Replace(" ", "", obj2)
        obj1 = Replace("\n", "", obj1)
        obj2 = Replace("\n", "", obj2)
        return obj1 == obj2
    end
end

local function printAllChars(str)
    local out = {}
    for i = 1, #str do
        Append(out, str:sub(i, i))
    end
    return out
end

local function splitStringInLinebreaks(str, maxWidth)
    local out = {}
    while string.len(str) > 0 do
        Append(out, string.sub(str, 1, maxWidth))
        str = string.sub(str, maxWidth + 1)
    end
    return out
end

local function printMinipage(caption, rows, i0, chunksize)
    local out = {}
    Append(out, [[\begin{minipage}[t]{.5\textwidth}]])
    if i0 == 1 then
        Append(out, caption .. ":")
    end
    Append(out, TexCmd("begin", "verbatim"))
    for i = i0, (i0 + chunksize - 1) do
        if i <= #rows then
            local rowcounter = tostring(i) .. " - "
            local splitRow = splitStringInLinebreaks(rows[i], 40)
            for key, line in pairs(splitRow) do
                if key == 1 then
                    line = rowcounter .. line
                else
                    for j = 1, string.len(rowcounter) do
                        line = "." .. line
                    end
                end
                Append(out, line)
            end
        end
    end
    Append(out, TexCmd("end", "verbatim"))
    Append(out, [[\end{minipage}]])
    return out
end

local function printComparison(expected, received)
    local out = {}
    local chunksize = 40
    local startIndex = 1
    while startIndex <= math.max(#expected, #received) do
        Append(out, printMinipage("Expected", expected, startIndex, chunksize))
        Append(out, printMinipage("Received", received, startIndex, chunksize))
        Append(out, [[\newpage]])
        startIndex = startIndex + chunksize
    end
    return out
end

function Assert(caller, expected, received)
    local failedIndex = { 0 }
    local failedItem1 = { "" }
    local failedItem2 = { "" }

    if IsDictionaryRandomised then
        caller = caller .. "-with-randomised-dictionary"
    end

    if HasError() then
        local out = {}
        numFailed = numFailed + 1
        Append(out, [[Error in function "]] .. caller .. [["!\\]])
        Append(out, PrintErrors())
        tex.print(out)
        ResetErrors()
    elseif areEqual(expected, received, failedIndex, failedItem1, failedItem2) then
        numSucceeded = numSucceeded + 1
    else
        local out = {}
        numFailed = numFailed + 1
        Append(out, [[Assert failed in function "]] .. caller .. [["!\\]])
        if type(expected) ~= type(received) then
            Append(out, "Expected output of type ")
            Append(out, type(expected) .. ",")
            Append(out, "but received output of type ")
            Append(out, type(received) .. [[.\\]])
        else
            Append(out, printComparison(expected, received))
            if type(failedItem1[1]) == "string" then
                Append(out, "At Element " .. failedIndex[1] .. [[:\\]])
                Append(out, printComparison(printAllChars(failedItem1[1]), printAllChars(failedItem2[1])))
            end
        end
        tex.print(out)
    end
end

function RunTests(testFiles)
    if IsEmpty(testFiles) then
        testFiles = allTestFiles
    end
    local out = {}

    for key, testfile in pairs(testFiles) do
        resetEnvironment()
        SelectLanguage("english")
        local currentlyFailed = numFailed
        dofile(RelativePath .. "/tests/" .. testfile .. ".lua")
        if currentlyFailed == numFailed then
            resetEnvironment()
            RandomiseDictionary()
            dofile(RelativePath .. "/tests/" .. testfile .. ".lua")
        end
    end

    Append(out, TexCmd("section*", "Results"))
    Append(out, TexCmd("RpgTex"))
    Append(out, " ran ")
    Append(out, numSucceeded + numFailed)
    Append(out, " tests, ")
    Append(out, numFailed)
    Append(out, " of which failed.")
    tex.print(out)
end
