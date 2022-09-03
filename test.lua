local testFiles = { "common", "refs" }
local numSucceeded = 0
local numFailed = 0

local function resetEnvironment()
    Entities = {}
    Histories = {}
end

local function areEqual(obj1, obj2)
    if type(obj1) ~= type(obj2) then
        return false
    elseif type(obj1) == "table" then
        if #obj1 ~= #obj2 then
            return false
        end
        for i = 1, #obj1 do
            if not areEqual(obj1[i], obj2[i]) then
                return false
            end
        end
        return true
    else
        return obj1 == obj2
    end
end

function Assert(caller, expected, out)
    if areEqual(expected, out) then
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
    Append(out, TexCmd("textsc", "Rpg"))
    Append(out, TexCmd("TeX"))
    Append(out, " ran ")
    Append(out, numSucceeded + numFailed)
    Append(out, " tests, ")
    Append(out, numFailed)
    Append(out, " of which failed.")
    tex.print(out)
end
