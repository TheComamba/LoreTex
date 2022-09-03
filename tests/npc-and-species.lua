NewEntity("test-species", "species", nil, "Test Species")
SetDescriptor(CurrentEntity(), "ageFactor", 0)

NewEntity("test-npc", "npc", nil, "Test NPC")
SetDescriptor(CurrentEntity(), "species", "test-species")

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {
    [[\chapter{Charaktere}]],
    [[\section*{Alle Charaktere}]],
    [[\begin{itemize}]],
    [[\footnotesize{}]],
    [[\item{} \itref{test-npc}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Test NPC}]],
    [[\label{test-npc}]],
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

Assert("npc-and-species", expected, out)