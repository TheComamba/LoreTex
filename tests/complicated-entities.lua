NewEntity("test-region", "place", nil, "Test Region")

NewEntity("test-city-1", "place", nil, "Test City 1")
SetDescriptor(CurrentEntity(), "location", "test-region")

NewEntity("test-city-2", "place", nil, "Test City 2")
SetDescriptor(CurrentEntity(), "location", "test-region")

NewEntity("test-species", "species", nil, "Test Species")
SetDescriptor(CurrentEntity(), "ageFactor", 0)

NewEntity("test-npc-1", "npc", nil, "Test NPC 1")
SetDescriptor(CurrentEntity(), "location", "test-city-1")
SetDescriptor(CurrentEntity(), "species", "test-species")

NewEntity("test-npc-2", "npc", nil, "Test NPC 2")
SetDescriptor(CurrentEntity(), "location", "test-city-2")
SetDescriptor(CurrentEntity(), "species", "test-species")

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {
    [[\chapter{Orte}]],
    [[\section*{Alle Orte}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \itref{test-city-1}]],
    [[\item{} \itref{test-city-2}]],
    [[\item{} \itref{test-region}]],
    [[\end{itemize}]],
    [[\section{Orte}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Test Region}]],
    [[\label{test-region}]],
    [[\paragraph{Orte}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \itref {test-city-1}]],
    [[\item{} \itref {test-city-2}]],
    [[\end{itemize}]],
    [[\subsection{In Test Region}]],
    [[\subsubsection{Test City 1}]],
    [[\label{test-city-1}]],
    [[\paragraph{NPCs}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \itref {test-npc-1}]],
    [[\end{itemize}]],
    [[\subsubsection{Test City 2}]],
    [[\label{test-city-2}]],
    [[\paragraph{NPCs}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \itref {test-npc-2}]],
    [[\end{itemize}]],
    [[\chapter{Charaktere}]],
    [[\section*{Alle Charaktere}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \itref{test-npc-1}]],
    [[\item{} \itref{test-npc-2}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In Test Region - Test City 1}]],
    [[\subsubsection{Test NPC 1}]],
    [[\label{test-npc-1}]],
    [[\paragraph{Erscheinung}]],
    [[\subparagraph{Spezies und Alter:}\itref {test-species}.]],
    [[\subsection{In Test Region - Test City 2}]],
    [[\subsubsection{Test NPC 2}]],
    [[\label{test-npc-2}]],
    [[\paragraph{Erscheinung}]],
    [[\subparagraph{Spezies und Alter:}\itref {test-species}.]],
    [[\chapter{Spezies}]],
    [[\section*{Alle Spezies}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \itref{test-species}]],
    [[\end{itemize}]],
    [[\section{Spezies}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Test Species}]],
    [[\label{test-species}]]
}

Assert("complicated-entities", expected, out)