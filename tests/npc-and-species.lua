NewEntity("test-species", "species", nil, "Test Species")

NewEntity("test-npc", "npc", nil, "Test NPC")
SetDescriptor(CurrentEntity(), "species", "test-species")
SetDescriptor(CurrentEntity(), "born", -20)

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {
    [[\chapter{Charaktere}]],
    [[\section*{Alle Charaktere}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-npc}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Test NPC}]],
    [[\label{test-npc}]],
    [[\paragraph{Erscheinung}]],
    [[\subparagraph{Spezies und Alter:}\nameref {test-species}, 20 Jahre alt.]],
    [[\paragraph{Histori\"e}]],
    [[\begin{itemize}]],
    [[\item{} -8 Vin (vor 8 Jahren): \nameref{test-npc} ist Jugendlich.]],
    [[\item{} 0 Vin (dieses Jahr): \nameref{test-npc} ist Jung.]],
    [[\end{itemize}]],
    [[\chapter{Spezies}]],
    [[\section*{Alle Spezies}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-species}]],
    [[\end{itemize}]],
    [[\section{Spezies}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Test Species}]],
    [[\label{test-species}]],
    [[\paragraph{Lebensabschnitte}]],
    [[\subparagraph{Kind} 0-12 Jahre
    \subparagraph{Jugendlich} 12-20 Jahre
    \subparagraph{Jung} 20-30 Jahre
    \subparagraph{Erwachsen} 30-60 Jahre
    \subparagraph{Alt} 60-90 Jahre
    \subparagraph{Uralt} 90+ Jahre]]
}

Assert("npc-and-species", expected, out)