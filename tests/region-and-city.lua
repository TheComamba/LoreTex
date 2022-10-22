NewEntity("test-continent", "places", nil, "Test Continent")

NewEntity("test-region", "places", nil, "Test Region")
SetLocation(CurrentEntity(), "test-continent")

NewEntity("test-city", "places", nil, "Test City")
SetLocation(CurrentEntity(), "test-region")

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\section{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-city}]],
    [[\item{} \nameref{test-continent}]],
    [[\item{} \nameref{test-region}]],
    [[\end{itemize}]],

    [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]],
    [[\subsubsection{Test Continent}]],
    [[\label{test-continent}]],
    [[\paragraph{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref {test-region}]],
    [[\end{itemize}]],

    [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Test Continent}]],
    [[\subsubsection{Test Region}]],
    [[\label{test-region}]],
    [[\paragraph{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref {test-city}]],
    [[\end{itemize}]],

    [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Test Continent - Test Region}]],
    [[\subsubsection{Test City}]],
    [[\label{test-city}]]
}

Assert("region-and-city", expected, out)
