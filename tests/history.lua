NewEntity("test-1", "places", nil, "Test 1")
AddEvent(CurrentEntity(), -20, [[Some event.]])
AddEvent(nil, -10, [[Event that concerns \reference{test-1}.]])
AddEvent(CurrentEntity(), 5, [[Event in the future.]])

AddAllEntitiesToPrimaryRefs()

IsShowFuture = false
local out = AutomatedChapters()

local expected = {
    [[\chapter{Places}]],
    [[\section*{All Places}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-1}]],
    [[\end{itemize}]],
    [[\section{Places}]],
    [[\subsection{In the whole World}]],
    [[\subsubsection{Test 1}]],
    [[\label{test-1}]],
    [[\paragraph{History}]],
    [[\begin{itemize}]],
    [[\item{} -20 Vin (20 years ago): Some event.]],
    [[\item{} -10 Vin (10 years ago): Event that concerns \nameref{test-1}.]],
    [[\end{itemize}]]
}

Assert("history-events-no-future", expected, out)

IsShowFuture = true
out = AutomatedChapters()

expected = {
    [[\chapter{Places}]],
    [[\section*{All Places}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-1}]],
    [[\end{itemize}]],
    [[\section{Places}]],
    [[\subsection{In the whole World}]],
    [[\subsubsection{Test 1}]],
    [[\label{test-1}]],
    [[\paragraph{History}]],
    [[\begin{itemize}]],
    [[\item{} -20 Vin (20 years ago): Some event.]],
    [[\item{} -10 Vin (10 years ago): Event that concerns \nameref{test-1}.]],
    [[\item{} 5 Vin (in 5 years): Event in the future.]],
    [[\end{itemize}]]
}

Assert("history-events-with-future", expected, out)