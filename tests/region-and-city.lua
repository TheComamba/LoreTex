NewEntity("test-region", "places", nil, "Test Region")

NewEntity("test-city", "places", nil, "Test City")
SetDescriptor(CurrentEntity(), "location", "test-region")

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {
    [[\chapter{]] .. Tr("places") .. [[}]],
    [[\section*{]] .. Tr("all") .. [[ ]] .. Tr("places") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-city}]],
    [[\item{} \nameref{test-region}]],
    [[\end{itemize}]],
    [[\section{]] .. Tr("places") .. [[}]],
    [[\subsection{]] .. Tr("in-whole-world") .. [[}]],
    [[\subsubsection{Test Region}]],
    [[\label{test-region}]],
    [[\paragraph{]] .. Tr("places") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref {test-city}]],
    [[\end{itemize}]],
    [[\subsection{In Test Region}]],
    [[\subsubsection{Test City}]],
    [[\label{test-city}]]
}

Assert("region-and-city", expected, out)
