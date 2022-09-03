local list = { "a", "b", "c" }
local expected = [[\begin{itemize}\footnotesize{}\item{} a\item{} b\item{} c\end{itemize}]]
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
    { [[\myref]], [[\ref]], [[Well, \myref{cake} is here.]], [[Well, \ref{cake} is here.]] },
    { [[e]], [[]], [[Several Occurrences]], [[Svral Occurrncs]]},
    { [[poof]], [[bang]], [[No Occurence]], [[No Occurence]] }
}
for key, args in pairs(ReplaceTestArgs) do
    Assert("Replace", args[4], Replace(args[1], args[2], args[3]))
end

local emptyThings = {
    nil, {}, "", " \t \n ", [[ 


    ]]
}
for key, thing in pairs(emptyThings) do
    Assert("IsEmpty", true, IsEmpty(thing))
end