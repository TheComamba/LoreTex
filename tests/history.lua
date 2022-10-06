NewEntity("test-1", "place", nil, "Test 1")
AddEvent(CurrentEntity(), -20, [[Some event.]])
AddEvent(nil, -10, [[Event that concerns \reference{test-1}.]])

AddAllEntitiesToPrimaryRefs()
local out = AutomatedChapters()

local expected = {
    [[\chapter{Orte}]],
    [[\section*{Alle Orte}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-1}]],
    [[\end{itemize}]],
    [[\section{Orte}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Test 1}]],
    [[\label{test-1}]],
    [[\paragraph{Histori\"e}]],
    [[\begin{itemize}]],
    [[\item{} -20 Vin (vor 20 Jahren): Some event.]],
    [[\item{} -10 Vin (vor 10 Jahren): Event that concerns \nameref{test-1}.]],
    [[\end{itemize}]]
}

Assert("history-events", expected, out)