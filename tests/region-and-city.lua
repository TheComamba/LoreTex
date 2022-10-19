NewEntity("test-region", "places", nil, "Test Region")

NewEntity("test-city", "places", nil, "Test City")
SetDescriptor(CurrentEntity(), "location", "test-region")

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {
    [[\chapter{Places}]],
    [[\section*{All Places}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-city}]],
    [[\item{} \nameref{test-region}]],
    [[\end{itemize}]],
    [[\section{Places}]],
    [[\subsection{In the whole World}]],
    [[\subsubsection{Test Region}]],
    [[\label{test-region}]],
    [[\paragraph{Places}]],
    [[\begin{itemize}]],
    [[\item{} \nameref {test-city}]],
    [[\end{itemize}]],
    [[\subsection{In Test Region}]],
    [[\subsubsection{Test City}]],
    [[\label{test-city}]]
}

Assert("region-and-city", expected, out)