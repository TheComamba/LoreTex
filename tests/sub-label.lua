NewEntity("npcs", "some-npc", nil, "Some NPC")
SetSpecies(CurrentEntity(), "subspecies")
SetLocation(CurrentEntity(), "subplace-1")
SetDescriptor(CurrentEntity(), "Info 1", [[Refers to \nameref{subplace-2}.]])
SetDescriptor(CurrentEntity(), "Info 2", [[Refers to \nameref{subplace-3}.]])
SetDescriptor(CurrentEntity(), "Info 3", [[Refers to \nameref{subplace-4}.]])
NewEntity("places", "place-1", nil, "Place 1")
SetDescriptor(CurrentEntity(), "Subplace 1", [[\label{subplace-1}]])
NewEntity("places", "place-2", nil, "Place 2")
SetDescriptor(CurrentEntity(), "Subplace 2", [[\label{subplace-2}]])
SetDescriptor(CurrentEntity(), "More Subplaces",
    [[\subparagraph{Subplace 3} \label{subplace-3}
\subparagraph{Subplace 4} \label{subplace-4}]])
NewEntity("species", "species", nil, "Species")
SetDescriptor(CurrentEntity(), "Subspecies", [[\label{subspecies}]])

AddRef("some-npc", PrimaryRefs)

local out = AutomatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{some-npc}]],
    [[\end{itemize}]],
    [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Subplace 1}]],
    [[\subsubsection{Some NPC}]],
    [[\label{some-npc}]],
    [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]],
    [[\subparagraph{]] .. CapFirst(Tr("species-and-age")) .. [[:}\nameref {subspecies}.]],
    [[\paragraph{Info 1}]],
    [[Refers to \nameref{subplace-2}.]],
    [[\paragraph{Info 2}]],
    [[Refers to \nameref{subplace-3}.]],
    [[\paragraph{Info 3}]],
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
