TexApi.newEntity { type = "NPCs", label = "test", name = "Test" }

local function refSetup()
    TexApi.addType { metatype = "characters", type = "NPCs" }
    TexApi.makeAllEntitiesOfTypePrimary("characters")
end

local expected = {}
Append(expected, [[\chapter{Characters}]])
Append(expected, [[\section{NPCs}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{test}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsubsection{Test}]])
Append(expected, [[\label{test}]])

AssertAutomatedChapters("make-primary-if", expected, refSetup)
