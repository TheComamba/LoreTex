NewEntity("npc", "npc", nil, "NPC")
SetDescriptor(CurrentEntity(), "species", "subspecies")
SetDescriptor(CurrentEntity(), "location", "subplace-1")
SetDescriptor(CurrentEntity(), "Some Info", [[Refers to \nameref{subplace-2}.]])
NewEntity("place-1", "place", nil, "Place 1")
SetDescriptor(CurrentEntity(), "Subplace 1", [[\label{subplace-1}]])
NewEntity("place-2", "place", nil, "Place 2")
SetDescriptor(CurrentEntity(), "Subplace 2", [[\label{subplace-2}]])
NewEntity("species", "species", nil, "Species")
SetDescriptor(CurrentEntity(), "Subspecies", [[\label{subspecies}]])

AddRef("npc", PrimaryRefs)

local out = AutomatedChapters()

local expected = {
    [[\chapter{Charaktere}]],
    [[\section*{Alle Charaktere}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{npc}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In Subplace 1}]],
    [[\subsubsection{NPC}]],
    [[\label{npc}]],
    [[\paragraph{Erscheinung}]],
    [[\subparagraph{Spezies und Alter:}\nameref {subspecies}.]],
    [[\paragraph{Some Info}]],
    [[Refers to \nameref{subplace-2}.]],
    [[\chapter{Nur erwähnt}]],
    [[\subparagraph{Subplace 2}]],
    [[\label{subplace-2}]],
    [[\hspace{1cm}]],
    [[\subparagraph{Subspecies}]],
    [[\label{subspecies}]],
    [[\hspace{1cm}]]
}

Assert("sub-label", expected, out)
