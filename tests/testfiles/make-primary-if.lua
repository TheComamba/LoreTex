TexApi.newEntity { type = "NPCs", label = "test", name = "Test" }

local function refSetup()
    TexApi.makeAllEntitiesOfTypePrimary("NPCs")
end

local expected = {}
Append(expected, [[\chapter{NPCs}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{test}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsection{Test}]])
Append(expected, [[\label{test}]])

AssertAutomatedChapters("make-primary-if", expected, refSetup)
