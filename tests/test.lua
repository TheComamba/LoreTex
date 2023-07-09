local allTestFiles = {}
Append(allTestFiles, "age-modifiers")
Append(allTestFiles, "aging-subentities")
Append(allTestFiles, "calendars")
Append(allTestFiles, "common")
Append(allTestFiles, "comparer")
Append(allTestFiles, "default-location")
Append(allTestFiles, "deferred-entities")
Append(allTestFiles, "descriptors")
Append(allTestFiles, "dictionary")
Append(allTestFiles, "entities-with-associations")
Append(allTestFiles, "entities-with-history")
Append(allTestFiles, "entity-visibility")
Append(allTestFiles, "entity-visibility-2")
Append(allTestFiles, "ffi-convert")
Append(allTestFiles, "height-descriptor")
Append(allTestFiles, "histories-with-offsets")
Append(allTestFiles, "history-item-counts")
Append(allTestFiles, "history")
Append(allTestFiles, "make-primary-if")
Append(allTestFiles, "making-entities-primary")
Append(allTestFiles, "marked-entities")
Append(allTestFiles, "mentioned-refs")
Append(allTestFiles, "nested-entities")
Append(allTestFiles, "npc-and-species")
Append(allTestFiles, "primary-when-mentioned-type")
Append(allTestFiles, "refs")
Append(allTestFiles, "region-and-city")
Append(allTestFiles, "ship-crew")
Append(allTestFiles, "species-at-location")
Append(allTestFiles, "sub-label")
Append(allTestFiles, "types")
local numFailed = 0
local isContainedTranslation = false
local apiFunctionUsage = {}

local function printMinipage(caption, rows, i0, chunksize)
    local out = {}
    Append(out, [[\begin{minipage}[t]{.5\textwidth}]])
    if i0 == 1 then
        Append(out, caption .. ":")
    end
    Append(out, TexCmd("begin", "verbatim"))
    local iMax = math.min(i0 + chunksize - 1, #rows)
    for i = i0, iMax do
        local splitRow = SplitStringInLinebreaks(rows[i], 50)
        Append(out, splitRow)
    end
    Append(out, TexCmd("end", "verbatim"))
    Append(out, [[\end{minipage}]])
    return out
end

local function printStringComparison(expected, received)
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

local function onAssertionFail(caller, message)
    numFailed = numFailed + 1
    local out = {}
    Append(out, [[Assert failed in function "]] .. caller .. [["!\\]])
    Append(out, message)
    Append(out, [[\newpage]])
    tex.print(out)
end

local function checkForErrors(caller)
    if HasError() then
        local out = {}
        Append(out, [[Error in function "]] .. caller .. [["!\\]])
        Append(out, PrintErrors())

        onAssertionFail(caller, out)
        ResetErrors()
    end
end

local function checkOutputTypes(caller, expected, received)
    if type(expected) ~= type(received) then
        local out = {}
        Append(out, "Expected output of type ")
        Append(out, type(expected) .. ",")
        Append(out, "but received output of type ")
        Append(out, type(received) .. [[.\\]])

        onAssertionFail(caller, out)
    end
end

local function toPrintableString(inp)
    local out = inp
    if not out then
        return "nil"
    elseif type(out) ~= "string" then
        out = tostring(out)
    end
    out = Replace(" ", "", out)
    out = Replace("\n", "", out)
    out = Replace([[_]], [[\_]], out)
    return out
end

local function areStringEqual(str1, str2)
    return toPrintableString(str1) == toPrintableString(str2)
end

local function checkOutputValues(caller, expected, received)
    if not expected or not received then return end
    local expectedString = DebugPrintRaw(expected)
    local receivedString = DebugPrintRaw(received)
    for i = 1, math.max(#expectedString, #receivedString) do
        if expectedString[i] == nil or receivedString[i] == nil or not areStringEqual(expectedString[i], receivedString[i]) then
            local out = {}
            Append(out, "Mismatch at position ")
            Append(out, i)
            Append(out, [[:]])
            Append(out, DebugPrint(expectedString[i]))
            Append(out, [[!=]])
            Append(out, DebugPrint(receivedString[i]))
            Append(out, printStringComparison(expectedString, receivedString))

            onAssertionFail(caller, out)
            return
        end
    end
end

function Assert(caller, expected, received)
    if IsDictionaryRandomised then
        caller = caller .. ", with randomised dictionary"
    end

    checkForErrors(caller)
    checkOutputTypes(caller, expected, received)
    checkOutputValues(caller, expected, received)
end

function AssertAutomatedChapters(caller, expected, setup)
    if setup then
        setup()
    end
    local out = TexApi.automatedChapters()
    Assert(caller, expected, out)

    local dbName = os.tmpname()
    TexApi.writeLoreToDatabase(dbName)
    ResetState()
    TexApi.readLoreFromDatabase(dbName)
    os.remove(dbName)

    if setup then
        setup()
    end
    out = TexApi.automatedChapters()
    Assert(caller .. ", read from Database", expected, out)
    ResetState()
end

local function prepareFunctionsWrappers()
    for key, fun in pairs(TexApi) do
        apiFunctionUsage[key] = 0
        local actualFunction = TexApi[key]
        TexApi[key] = function(...)
            apiFunctionUsage[key] = apiFunctionUsage[key] + 1
            return actualFunction(...)
        end
    end
    local actualTr = Tr
    Tr = function(a, b)
        isContainedTranslation = true
        return actualTr(a, b)
    end
end

local function runTests(testFiles)
    if IsEmpty(testFiles) then
        testFiles = allTestFiles
    end

    for key, testfile in pairs(testFiles) do
        ResetState()
        PushScopedVariables()
        TexApi.selectLanguage("english")
        local currentlyFailed = numFailed
        dofile(RelativePath .. "../tests/testfiles/" .. testfile .. ".lua")
        PopScopedVariables()

        if currentlyFailed == numFailed and isContainedTranslation then
            ResetState()
            PushScopedVariables()
            RandomiseDictionary()
            dofile(RelativePath .. "../tests/testfiles/" .. testfile .. ".lua")
            PopScopedVariables()
            isContainedTranslation = false
        end
    end
end

local function printResults()
    local out = {}
    Append(out, TexCmd("section*", "Results"))
    Append(out, numFailed)
    Append(out, TexCmd(" LoreTex tests failed."))
    Append(out, [[\newline]])
    Append(out, "Usage of TexApi functions:")
    local apiFunctionUsageOutput = {}
    for key, usage in pairs(apiFunctionUsage) do
        local usageStr = ""
        if usage == 0 then
            usageStr = " was not called!!!"
        elseif usage == 1 then
            usageStr = " was called only once!"
        else
            usageStr = " was called " .. usage .. " times."
        end
        Append(apiFunctionUsageOutput, TexCmd("LoreTexSort", usage) .. key .. usageStr)
    end
    Sort(apiFunctionUsageOutput, "compareAlphanumerical")
    Append(out, ListAll(apiFunctionUsageOutput))
    return out
end

function LoreTexTests(testFiles)
    prepareFunctionsWrappers()
    runTests(testFiles)
    if IsThrowOnError and numFailed > 0 then
        error("Some asserts failed.")
    else
        tex.print(printResults())
    end
end
