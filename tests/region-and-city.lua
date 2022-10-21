NewEntity("test-region", "places", nil, "Test Region")

NewEntity("test-city", "places", nil, "Test City")
SetDescriptor(CurrentEntity(), "location", "test-region")

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-city}]],
    [[\item{} \nameref{test-region}]],
    [[\end{itemize}]],
    [[\section{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]],
    [[\subsubsection{Test Region}]],
    [[\label{test-region}]],
    [[\paragraph{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref {test-city}]],
    [[\end{itemize}]],
    [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Test Region}]],
    [[\subsubsection{Test City}]],
    [[\label{test-city}]]
}

Assert("region-and-city", expected, out)
