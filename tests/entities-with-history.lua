NewEntity("test-1", "place", nil, "Test 1")

NewEntity("test-2", "place", nil, "Test 2")
AddEvent(CurrentEntity(), -10, [[Event that concerns \reference{test-1} and \itref{test-2}.]])
AddEvent(CurrentEntity(), 10, [[Event in the future.]])

AddRef("test-1", PrimaryRefs)

IsShowFuture = false

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
    [[\item{} -10 Vin (vor 10 Jahren): Event that concerns \nameref{test-1} and \itref{test-2}.]],
    [[\end{itemize}]],
    [[\chapter{Nur erwähnt}]],
    [[\subparagraph{Test 2}]],
    [[\label{test-2}]],
    [[\hspace{1cm}]]
}

Assert("one-entity-with-history", expected, out)

AddRef("test-2", PrimaryRefs)

out = AutomatedChapters()

expected = {
    [[\chapter{Orte}]],
    [[\section*{Alle Orte}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-1}]],
    [[\item{} \nameref{test-2}]],
    [[\end{itemize}]],
    [[\section{Orte}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Test 1}]],
    [[\label{test-1}]],
    [[\paragraph{Histori\"e}]],
    [[\begin{itemize}]],
    [[\item{} -10 Vin (vor 10 Jahren): Event that concerns \nameref{test-1} and \itref{test-2}.]],
    [[\end{itemize}]],
    [[\subsubsection{Test 2}]],
    [[\label{test-2}]],
    [[\paragraph{Histori\"e}]],
    [[\begin{itemize}]],
    [[\item{} -10 Vin (vor 10 Jahren): Event that concerns \nameref{test-1} and \itref{test-2}.]],
    [[\end{itemize}]]
}

Assert("two-entities-with-history", expected, out)
