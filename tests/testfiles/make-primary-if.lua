TexApi.newEntity { type = "npcs", label = "test", name = "Test" }

local function refSetup()
    TexApi.addType { metatype = "characters", type = "npcs" }
    TexApi.makeAllEntitiesOfTypePrimary("characters")
end

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{test}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsubsection{Test}]])
Append(expected, [[\label{test}]])

AssertAutomatedChapters("make-primary-if", expected, refSetup)
