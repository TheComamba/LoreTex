TexApi.newEntity { category = "places", label = "test-continent", name = "Test Continent" }

TexApi.newEntity { category = "places", label = "test-region", name = "Test Region" }
TexApi.setLocation("test-continent")

TexApi.newEntity { category = "places", label = "test-city", name = "Test City" }
TexApi.setLocation("test-region")

local function setup()
    TexApi.makeAllEntitiesPrimary()
end

local expected = {
    [[\chapter{Places}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. [[ Places}]],
    [[\begin{itemize}]],
    [[\item \nameref{test-city}]],
    [[\item \nameref{test-continent}]],
    [[\item \nameref{test-region}]],
    [[\end{itemize}]],

    [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]],
    [[\subsection{Test Continent}]],
    [[\label{test-continent}]],
    [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ Places}]],
    [[\begin{itemize}]],
    [[\item \nameref {test-region}]],
    [[\end{itemize}]],

    [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Test Continent}]],
    [[\subsection{Test Region}]],
    [[\label{test-region}]],
    [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ Places}]],
    [[\begin{itemize}]],
    [[\item \nameref {test-city}]],
    [[\end{itemize}]],

    [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Test Continent - Test Region}]],
    [[\subsection{Test City}]],
    [[\label{test-city}]]
}

AssertAutomatedChapters("region-and-city", expected, setup)
