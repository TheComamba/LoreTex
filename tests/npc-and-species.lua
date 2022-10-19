NewEntity("test-species", "species", nil, "Test Species")

NewEntity("test-npc", "npcs", nil, "Test NPC")
SetDescriptor(CurrentEntity(), "species", "test-species")
SetDescriptor(CurrentEntity(), "born", -20)

AddAllEntitiesToPrimaryRefs()

IsShowFuture = false
local out = AutomatedChapters()

local expected = {
    [[\chapter{Characters}]],
    [[\section*{All Characters}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-npc}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In the whole World}]],
    [[\subsubsection{Test NPC}]],
    [[\label{test-npc}]],
    [[\paragraph{Appearance}]],
    [[\subparagraph{Species and Age:}\nameref {test-species}, 20 years old.]],
    [[\paragraph{History}]],
    [[\begin{itemize}]],
    [[\item{} -8 Vin (8 years ago): \nameref{test-npc} is Juvenile.]],
    [[\item{} 0 Vin (this year): \nameref{test-npc} is Young.]],
    [[\end{itemize}]],
    [[\chapter{Species}]],
    [[\section*{All Species}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-species}]],
    [[\end{itemize}]],
    [[\section{Spezies}]],
    [[\subsection{In the whole World}]],
    [[\subsubsection{Test Species}]],
    [[\label{test-species}]],
    [[\paragraph{Stages of Life}]],
    [[\subparagraph{Child} 0-12 Years
    \subparagraph{Juvenile} 12-20 Years
    \subparagraph{Young} 20-30 Years
    \subparagraph{Adult} 30-60 Years
    \subparagraph{Old} 60-90 Years
    \subparagraph{Ancient} 90+ Years]]
}

Assert("npc-and-species", expected, out)