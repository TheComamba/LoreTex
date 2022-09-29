local tab = { { "a", "b" },
    { "c", "d" } }

local expected = { [[\tablehead{\clmhead{a}&\clmhead{b}\\\hline}]],
    [[\begin{center}]],
    [[\begin{supertabular}]],
    [[{]],
    [[p{0.224\textwidth}]],
    [[p{0.224\textwidth}]],
    [[}]],
    [[c]],
    [[&]],
    [[d]],
    [[\\]],
    [[\end{supertabular}]],
    [[\end{center}]]
}

Assert("PrintTable", expected, PrintTable(tab))
