local list = { "a", "b", "c" }
local expected = { [[\begin{itemize}]],
    [[\item a]],
    [[\item b]],
    [[\item c]],
    [[\end{itemize}]] }
Assert("ListAll", expected, ListAll(list))

local FirstNonWhitespaceCharTestArgs = {
    { [[]], nil },
    { [[     ]], nil },
    { [[ABC]], 1 },
    { [[ABC   ]], 1 },
    { [[ AB C]], 2 },
    { [[ Ä]], 2 },
    { [[ \]], 2 },
    { "\t \nA", 4 },
    { [[

    A
    ]], 6 }
}
for key, inAndOut in pairs(FirstNonWhitespaceCharTestArgs) do
    Assert("FirstNonWhitespaceChar", inAndOut[2], FirstNonWhitespaceChar(inAndOut[1]))
end

local ReplaceTestArgs = {
    { [[Har]], [[De]], [[Harmonic minor]], [[Demonic minor]] },
    { [[\reference]], [[\nameref]], [[Well, \reference{cake} is here.]], [[Well, \nameref{cake} is here.]] },
    { [[e]], [[]], [[Several Occurrences]], [[Svral Occurrncs]] },
    { [[poof]], [[bang]], [[No Occurence]], [[No Occurence]] }
}
for key, args in pairs(ReplaceTestArgs) do
    Assert("Replace", args[4], Replace(args[1], args[2], args[3]))
end

local emptyThings = {
    nil, {}, { {}, { { {}, {} } } }, "", " \t \n ", [[ 


    ]], ReadonlyTable({}), ReadonlyTable(nil)
}
for key, thing in pairs(emptyThings) do
    Assert("IsEmpty", true, IsEmpty(thing))
end


local AppendTestArgs = {
    { {}, 1, { 1 } },
    { { 1 }, { "str", true, { "in table" } }, { 1, "str", true, "in table" } },
    { {}, { {} }, {} }
}

for key, args in pairs(AppendTestArgs) do
    Append(args[1], args[2])
    Assert("Append", args[3], args[1])
end

local UniqueAppendTestArgs = AppendTestArgs
UniqueAppendTestArgs[#UniqueAppendTestArgs + 1] = { { 3, 4, 5 }, { 5, 6, 7 }, { 3, 4, 5, 6, 7 } }
UniqueAppendTestArgs[#UniqueAppendTestArgs + 1] = { {}, { true, { "true", { true, { 1 } } } }, { true, "true", 1 } }

for key, args in pairs(UniqueAppendTestArgs) do
    UniqueAppend(args[1], args[2])
    Assert("Append", args[3], args[1])
end

local aTable = { "value1", { "value2" } }
local shallowCopy = aTable
local deepCopy = DeepCopy(aTable)
aTable[2][1] = "new value"
Assert("ShallowCopy", { "value1", { "new value" } }, shallowCopy)
Assert("DeepCopy", { "value1", { "value2" } }, deepCopy)
