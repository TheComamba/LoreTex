function RunTests()
    local out = {}
    local numSucceeded = 0
    local numFaield = 0
    Append(out, TexCmd("textsc", "Rpg"))
    Append(out, TexCmd("TeX"))
    Append(out, " ran ")
    Append(out, numSucceeded + numFaield)
    Append(out, " test, ")
    Append(out, numFaield)
    Append(out, " of which failed.")
    tex.print(table.concat(out))
end