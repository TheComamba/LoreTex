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

local tab = { { "a", "b", "c" },
    { "d", "e", "f" } }

local expected = { [[\tablehead{\clmhead{a}&\clmhead{b}&\clmhead{c}\\\hline}]],
    [[\begin{center}]],
    [[\begin{supertabular}]],
    [[{]],
    [[p{0.142\textwidth}]],
    [[p{0.142\textwidth}]],
    [[p{0.142\textwidth}]],
    [[}]],
    [[d]],
    [[&]],
    [[e]],
    [[&]],
    [[f]],
    [[\\]],
    [[\end{supertabular}]],
    [[\end{center}]]
}

Assert("PrintTable", expected, PrintTable(tab))

local tab = { { "a", "b", "c", "d" },
    { "e", "f", "g", "h" } }

local expected = { [[\tablehead{\clmhead{a}&\clmhead{b}&\clmhead{c}&\clmhead{d}\\\hline}]],
    [[\begin{center}]],
    [[\begin{supertabular}]],
    [[{]],
    [[p{0.101\textwidth}]],
    [[p{0.101\textwidth}]],
    [[p{0.101\textwidth}]],
    [[p{0.101\textwidth}]],
    [[}]],
    [[e]],
    [[&]],
    [[f]],
    [[&]],
    [[g]],
    [[&]],
    [[h]],
    [[\\]],
    [[\end{supertabular}]],
    [[\end{center}]]
}

Assert("PrintTable", expected, PrintTable(tab))
