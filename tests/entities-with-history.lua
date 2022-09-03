NewEntity("test-1", "place", nil, "Test 1")

NewEntity("test-2", "place", nil, "Test 2")
AddEvent(CurrentEntity(), -10, [[Event that concerns \myref{test-1} and \myref{test-2}.]])
AddEvent(CurrentEntity(), 10, [[Event in the future.]])

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {
    [[\chapter{Orte}]],
    [[\section*{Alle Orte}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \itref{test-1}]],
    [[\item{} \itref{test-2}]],
    [[\end{itemize}]],
    [[\section{Orte}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Test 1}]],
    [[\label{test-1}]],
    [[\paragraph{Histori\"e}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} -10 Vin (vor 10 Jahren): Event that concnerns \itref{test-
    1} and \itref{test-2}.]],
    [[\end{itemize}]],
    [[\subsubsection{Test 2}]],
    [[\label{test-2}]],
    [[\paragraph{Histori\"e}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} -10 Vin (vor 10 Jahren): Event that concnerns \itref{test-
    1} and \itref{test-2}.]],
    [[\end{itemize}]]
}

Assert("entities-with-history", expected, out)
