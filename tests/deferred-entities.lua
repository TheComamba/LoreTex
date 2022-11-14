TexApi.setCurrentYear(0)
TexApi.newEntity { label = "unimportant", type = "places", name = "Unimportant" }
TexApi.addHistory { year = 0, event = [[Mentions \nameref{deferred-entity-1}.]] }
TexApi.addHistory { year = 0, event = [[Mentions \nameref{deferred-entity-2-alias}.]] }
TexApi.newEntity { label = "deferred-entity-1", type = "places", name = "Deferred 1" }
TexApi.newEntity { label = "deferred-entity-2", type = "places", name = "Deferred 2" }
TexApi.setDescriptor { descriptor = "Alias", description = [[\label{deferred-entity-2-alias}]] }
AddRef("deferred-entity-1", PrimaryRefs)
AddRef("deferred-entity-2", PrimaryRefs)
local expected = {}
Append(expected, [[\chapter(]] .. CapFirst(Tr("places")) .. [[)]])
Append(expected, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{deferred-entity-1}]])
Append(expected, [[\item \nameref{deferred-entity-2}]])
Append(expected, [[\item \nameref{deferred-entity-2-alias}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])

Append(expected, [[\subsubsection{Deferred 1}]])
Append(expected, [[\label{deferred-entity-1}]])
Append(expected, [[\subsubsection{Deferred 2}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item 0 (]] .. Tr("this-year") .. [[):\\Mentions \nameref{deferred-entity-1}.]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\label{deferred-entity-2}]])
Append(expected, [[\paragraph{Alias}]])
Append(expected, [[\label{deferred-entity-2-alias}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item 0 (]] .. Tr("this-year") .. [[):\\Mentions \nameref{deferred-entity-2-alias}.]])
Append(expected, [[\end{itemize}]])

local out = TexApi.automatedChapters()

Assert("Deferred Entities", expected, out)
