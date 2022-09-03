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
        numFailed = numFailed + 1
        tex.print([[Error in function "]] .. caller .. [["!\\]])
        if type(expected) ~= type(out) then
            tex.print("Expected output of type ")
            tex.print(type(expected) .. ",")
            tex.print("but received output of type ")
            tex.print(type(out) .. [[.\\]])
        else
            tex.print("Expected: ")
            tex.print(TexCmd("begin", "verbatim"))
            tex.print(expected)
            tex.print(TexCmd("end", "verbatim"))
            tex.print("Received:")
            tex.print(TexCmd("begin", "verbatim"))
            tex.print(out)
            tex.print(TexCmd("end", "verbatim"))
        end
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
    tex.print(table.concat(out))
end
