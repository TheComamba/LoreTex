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
local numSucceeded = 0
local numFailed = 0
local isContainedTranslation = false
local apiFunctionUsage = {}
local testFunctions = {}

testFunctions.areEntitiesWithSameLabel = function(obj1, obj2)
    if obj1 == nil or obj2 == nil then
        return false
    elseif not IsEntity(obj1) or not IsEntity(obj2) then
        return false
    else
        return GetProtectedStringField(obj1, "label") == GetProtectedStringField(obj2, "label")
    end
end

testFunctions.areTablesEqual = function(obj1, obj2, elementNum, currentObj1, currentObj2)
    if #obj1 ~= #obj2 then
        elementNum[1] = -1
        currentObj1[1] = #obj1
        currentObj2[1] = #obj2
        return false
    end
    for key, value in pairs(obj1) do
        if not testFunctions.areEntitiesWithSameLabel(value, obj2[key]) or
            not testFunctions.areEqual(value, obj2[key], elementNum, currentObj1, currentObj2) then
            if IsProtectedDescriptor(key) then
                key = [[$]] .. key .. [[$]]
            end
            elementNum[1] = key
            currentObj1[1] = obj1[key]
            currentObj2[1] = obj2[key]
            return false
        end
    end
    return true
end

testFunctions.areEqual = function(obj1, obj2, elementNum, currentObj1, currentObj2)
    if obj1 == nil or obj2 == nil then
        if obj1 == nil and obj2 == nil then
            return true
        else
            return false
        end
    elseif type(obj1) ~= type(obj2) then
        return false
    elseif type(obj1) == "table" then
        return testFunctions.areTablesEqual(obj1, obj2, elementNum, currentObj1, currentObj2)
    else
        obj1 = Replace(" ", "", obj1)
        obj2 = Replace(" ", "", obj2)
        obj1 = Replace("\n", "", obj1)
        obj2 = Replace("\n", "", obj2)
        obj1 = Replace([[_]], [[\_]], obj1)
        obj2 = Replace([[_]], [[\_]], obj2)
        return obj1 == obj2
    end
end

testFunctions.printAllChars = function(str)
    local out = {}
    for i = 1, #str do
        Append(out, str:sub(i, i))
    end
    return out
end

testFunctions.splitStringInLinebreaks = function(str, maxWidth)
    local out = {}
    while string.len(str) > 0 do
        Append(out, string.sub(str, 1, maxWidth))
        str = string.sub(str, maxWidth + 1)
    end
    return out
end

testFunctions.printMinipage = function(caption, rows, i0, chunksize)
    local out = {}
    Append(out, [[\begin{minipage}[t]{.5\textwidth}]])
    if i0 == 1 then
        Append(out, caption .. ":")
    end
    Append(out, TexCmd("begin", "verbatim"))
    for i = i0, (i0 + chunksize - 1) do
        if i <= #rows then
            local rowcounter = tostring(i) .. " - "
            local splitRow = testFunctions.splitStringInLinebreaks(rows[i], 40)
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

testFunctions.printStringComparison = function(expected, received)
    local out = {}
    local chunksize = 40
    local startIndex = 1
    while startIndex <= math.max(#expected, #received) do
        Append(out, testFunctions.printMinipage("Expected", expected, startIndex, chunksize))
        Append(out, testFunctions.printMinipage("Received", received, startIndex, chunksize))
        Append(out, [[\newpage]])
        startIndex = startIndex + chunksize
    end
    return out
end

testFunctions.isListOfStrings = function(list)
    if type(list) ~= "table" then
        return false
    elseif #list == 0 then
        return false
    end
    for key, val in pairs(list) do
        if type(key) ~= "number" or type(val) ~= "string" then
            return false
        end
    end
    return true
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
    elseif testFunctions.areEqual(expected, received, failedIndex, failedItem1, failedItem2) then
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
            if testFunctions.isListOfStrings(expected) and testFunctions.isListOfStrings(received) then
                Append(out, testFunctions.printStringComparison(expected, received))
            else
                Append(out, testFunctions.printStringComparison(DebugPrintRaw(expected), DebugPrintRaw(received)))
            end
            if type(failedItem1[1]) == "string" and type(failedItem2[1]) == "string" then
                Append(out, "At Element " .. failedIndex[1] .. [[:\\]])
                local allCharsObj1 = testFunctions.printAllChars(failedItem1[1])
                local allCharsObj2 = testFunctions.printAllChars(failedItem2[1])
                Append(out, testFunctions.printStringComparison(allCharsObj1, allCharsObj2))
            else
            end
        end
        Append(out, [[\newpage]])
        tex.print(out)
    end
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
    Append(out, TexCmd("LoreTex"))
    Append(out, " ran ")
    Append(out, numSucceeded + numFailed)
    Append(out, " tests, ")
    Append(out, numFailed)
    Append(out, " of which failed.")
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
