TexApi.newEntity { type = "places", label = "test-continent", name = "Test Continent" }

TexApi.newEntity { type = "places", label = "test-region", name = "Test Region" }
TexApi.setLocation("test-continent")

TexApi.newEntity { type = "places", label = "test-city", name = "Test City" }
TexApi.setLocation("test-region")

AddAllEntitiesToPrimaryRefs()

local out = TexApi.automatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\section{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item \nameref{test-city}]],
    [[\item \nameref{test-continent}]],
    [[\item \nameref{test-region}]],
    [[\end{itemize}]],

    [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]],
    [[\subsubsection{Test Continent}]],
    [[\label{test-continent}]],
    [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("places") .. [[}]],
    [[\begin{itemize}]],
    [[\item \nameref {test-region}]],
    [[\end{itemize}]],

    [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Test Continent}]],
    [[\subsubsection{Test Region}]],
    [[\label{test-region}]],
    [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("places") .. [[}]],
    [[\begin{itemize}]],
    [[\item \nameref {test-city}]],
    [[\end{itemize}]],

    [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Test Continent - Test Region}]],
    [[\subsubsection{Test City}]],
    [[\label{test-city}]]
}

Assert("region-and-city", expected, out)
