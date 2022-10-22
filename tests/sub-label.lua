NewEntity("some-npc", "npcs", nil, "Some NPC")
SetSpecies(CurrentEntity(), "subspecies")
SetLocation(CurrentEntity(), "subplace-1")
SetDescriptor(CurrentEntity(), "Some Info", [[Refers to \nameref{subplace-2}.]])
SetDescriptor(CurrentEntity(), "Some More Info", [[Refers to \nameref{subplace-3}.]])
SetDescriptor(CurrentEntity(), "Even More Info", [[Refers to \nameref{subplace-4}.]])
NewEntity("place-1", "places", nil, "Place 1")
SetDescriptor(CurrentEntity(), "Subplace 1", [[\label{subplace-1}]])
NewEntity("place-2", "places", nil, "Place 2")
SetDescriptor(CurrentEntity(), "Subplace 2", [[\label{subplace-2}]])
SetDescriptor(CurrentEntity(), "More Subplaces", 
[[\subparagraph{Sublace 3} \label{subplace-3}
\subparagraph{Sublace 4} \label{subplace-4}]])
NewEntity("species", "species", nil, "Species")
SetDescriptor(CurrentEntity(), "Subspecies", [[\label{subspecies}]])

AddRef("some-npc", PrimaryRefs)

local out = AutomatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{npc}]],
    [[\end{itemize}]],
    [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\subsection{In Subplace 1}]],
    [[\subsubsection{Some NPC}]],
    [[\label{some-npc}]],
    [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]],
    [[\subparagraph{]] .. Tr("species-and-age") .. [[:}\nameref {subspecies}.]],
    [[\paragraph{Some Info}]],
    [[Refers to \nameref{subplace-2}.]],
    [[\paragraph{Some More Info}]],
    [[Refers to \nameref{subplace-3}.]],
    [[\paragraph{Even More Info}]],
    [[Refers to \nameref{subplace-4}.]],
    [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]],
    [[\subparagraph{Subplace 2}]],
    [[\label{subplace-2}]],
    [[\hspace{1cm}]],
    [[\subparagraph{Subplace 3}]],
    [[\label{subplace-3}]],
    [[\hspace{1cm}]],
    [[\subparagraph{Subplace 4}]],
    [[\label{subplace-4}]],
    [[\hspace{1cm}]],
    [[\subparagraph{Subspecies}]],
    [[\label{subspecies}]],
    [[\hspace{1cm}]]
}

Assert("sub-label", expected, out)
