NewEntity("npc", "npcs", nil, "NPC")
SetSpecies(CurrentEntity(), "subspecies")
SetLocation(CurrentEntity(), "subplace-1")
SetDescriptor(CurrentEntity(), "Some Info", [[Refers to \nameref{subplace-2}.]])
NewEntity("place-1", "places", nil, "Place 1")
SetDescriptor(CurrentEntity(), "Subplace 1", [[\label{subplace-1}]])
NewEntity("place-2", "places", nil, "Place 2")
SetDescriptor(CurrentEntity(), "Subplace 2", [[\label{subplace-2}]])
NewEntity("species", "species", nil, "Species")
SetDescriptor(CurrentEntity(), "Subspecies", [[\label{subspecies}]])

AddRef("npc", PrimaryRefs)

local out = AutomatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{npc}]],
    [[\end{itemize}]],
    [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\subsection{In Subplace 1}]],
    [[\subsubsection{NPC}]],
    [[\label{npc}]],
    [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]],
    [[\subparagraph{]] .. Tr("species-and-age") .. [[:}\nameref {subspecies}.]],
    [[\paragraph{Some Info}]],
    [[Refers to \nameref{subplace-2}.]],
    [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]],
    [[\subparagraph{Subplace 2}]],
    [[\label{subplace-2}]],
    [[\hspace{1cm}]],
    [[\subparagraph{Subspecies}]],
    [[\label{subspecies}]],
    [[\hspace{1cm}]]
}

Assert("sub-label", expected, out)
