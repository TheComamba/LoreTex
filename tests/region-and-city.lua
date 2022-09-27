NewEntity("test-region", "place", nil, "Test Region")

NewEntity("test-city", "place", nil, "Test City")
SetDescriptor(CurrentEntity(), "location", "test-region")

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {
    [[\chapter{Orte}]],
    [[\section*{Alle Orte}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \nameref{test-city}]],
    [[\item{} \nameref{test-region}]],
    [[\end{itemize}]],
    [[\section{Orte}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Test Region}]],
    [[\label{test-region}]],
    [[\paragraph{Orte}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \nameref {test-city}]],
    [[\end{itemize}]],
    [[\subsection{In Test Region}]],
    [[\subsubsection{Test City}]],
    [[\label{test-city}]]
}

Assert("region-and-city", expected, out)