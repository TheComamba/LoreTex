TexApi.newEntity { label = "char", type = "npcs", name = "char" }
TexApi.setDescriptor { descriptor = "sub", description = [[\subparagraph{subsub}\label{subsub}]] }
TexApi.born { year = -20, event = "Born." }
TexApi.makeEntityPrimary("char")

TexApi.setCurrentYear(0)

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{char}]])
Append(expected, [[\item \nameref{subsub}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection{char}]])
Append(expected, [[\label{char}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
Append(expected, [[\subparagraph{]] .. CapFirst(Tr("species-and-age")) .. [[}]])
Append(expected, [[20 ]] .. Tr("years-old"))
Append(expected, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item -20 (]] .. Tr("x-years-ago", { 20 }) .. [[):\\Born.]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\paragraph{Sub}]])
Append(expected, [[\subparagraph{Subsub}]])
Append(expected, [[\label{subsub}]])
local out = TexApi.automatedChapters()
Assert("Entity with subentities and age", expected, out)
