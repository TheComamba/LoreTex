local testFiles = { "common", "dictionary", "default-location", "entities-with-associations", "entities-with-history",
    "history", "npc-and-species", "refs", "region-and-city" }
local numSucceeded = 0
local numFailed = 0

local function resetEnvironment()
    AllEntities = {}
    Histories = {}
    CurrentYearVin = 0
    PrintHistoryYear = 0
    PrintHistoryDay = 0
    DefaultLocation = ""
    PrimaryRefs = {}
    SecondaryRefs = {}
    UnfoundRefs = {}
    IsShowFuture = true
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
        Append(out, "'" .. str:sub(i, i) .. "'")
    end
    return out
end

function Assert(caller, expected, out)
    local failedIndex = { 0 }
    local failedItem1 = { "" }
    local failedItem2 = { "" }
    if areEqual(expected, out, failedIndex, failedItem1, failedItem2) then
        numSucceeded = numSucceeded + 1
    else
        local message = {}
        numFailed = numFailed + 1
        Append(message, [[Error in function "]] .. caller .. [["!\\]])
        if type(expected) ~= type(out) then
            Append(message, "Expected output of type ")
            Append(message, type(expected) .. ",")
            Append(message, "but received output of type ")
            Append(message, type(out) .. [[.\\]])
        else
            Append(message, "Expected: ")
            Append(message, TexCmd("begin", "verbatim"))
            Append(message, expected)
            Append(message, TexCmd("end", "verbatim"))
            Append(message, "Received:")
            Append(message, TexCmd("begin", "verbatim"))
            Append(message, out)
            Append(message, TexCmd("end", "verbatim"))
            Append(message, "At Element " .. failedIndex[1] .. ":")
            Append(message, TexCmd("begin", "verbatim"))
            Append(message, failedItem1[1])
            Append(message, "!=")
            Append(message, failedItem2[1])
            if type(failedItem1[1]) == "string" then
                Append(message, "---")
                Append(message, printAllChars(failedItem1[1]))
                Append(message, "!=")
                Append(message, printAllChars(failedItem2[1]))
            end
            Append(message, TexCmd("end", "verbatim"))
        end
        tex.print(message)
    end
end

function RunTests()
    local out = {}

    for key, testfile in pairs(testFiles) do
        resetEnvironment()
        dofile(RelativePath .. "/tests/" .. testfile .. ".lua")
    end

    Append(out, TexCmd("section*", "Results"))
    Append(out, TexCmd("RPGTeX"))
    Append(out, " ran ")
    Append(out, numSucceeded + numFailed)
    Append(out, " tests, ")
    Append(out, numFailed)
    Append(out, " of which failed.")
    Append(out, PrintErrors())
    tex.print(out)
end
