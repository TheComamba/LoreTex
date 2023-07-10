TexApi.newEntity { type = "places", label = "test-continent", name = "Test Continent" }

TexApi.newEntity { type = "places", label = "test-region", name = "Test Region" }
TexApi.setLocation("test-continent")

TexApi.newEntity { type = "places", label = "test-city", name = "Test City" }
TexApi.setLocation("test-region")

local function setup()
    TexApi.makeAllEntitiesPrimary()
    TexApi.addType { metatype = "places", type = "places" }
end

local expected = {
    [[\chapter{Places}]],
    [[\section{Places}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ Places}]],
    [[\begin{itemize}]],
    [[\item \nameref{test-city}]],
    [[\item \nameref{test-continent}]],
    [[\item \nameref{test-region}]],
    [[\end{itemize}]],

    [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]],
    [[\subsubsection{Test Continent}]],
    [[\label{test-continent}]],
    [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ places}]],
    [[\begin{itemize}]],
    [[\item \nameref {test-region}]],
    [[\end{itemize}]],

    [[\subsection{]] .. CapFirst(Tr("located_in")) .. [[ Test Continent}]],
    [[\subsubsection{Test Region}]],
    [[\label{test-region}]],
    [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ places}]],
    [[\begin{itemize}]],
    [[\item \nameref {test-city}]],
    [[\end{itemize}]],

    [[\subsection{]] .. CapFirst(Tr("located_in")) .. [[ Test Continent - Test Region}]],
    [[\subsubsection{Test City}]],
    [[\label{test-city}]]
}

AssertAutomatedChapters("region-and-city", expected, setup)
