local testFiles = { "common" }
local numSucceeded = 0
local numFailed = 0

local function resetEnvironment()
    Entities = {}
    Histories = {}
end

function Assert(caller, expected, out)
    if expected == out then
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
