TexApi.newEntity { type = "npcs", label = "some-npc", name = "Some NPC" }
TexApi.setSpecies("subspecies")
TexApi.setLocation("subplace-1")
TexApi.setDescriptor { descriptor = "Info 1", description = [[Refers to \nameref{subplace-2}.]] }
TexApi.setDescriptor { descriptor = "Info 2", description = [[Refers to \nameref{subplace-3}.]] }
TexApi.setDescriptor { descriptor = "Info 3", description = [[Refers to \nameref{subplace-4}.]] }
TexApi.newEntity { type = "places", label = "place-1", name = "Place 1" }
TexApi.setDescriptor { descriptor = "Subplace 1", description = [[\label{subplace-1}]] }
TexApi.newEntity { type = "places", label = "place-2", name = "Place 2" }
TexApi.setDescriptor { descriptor = "Subplace 2", description = [[\label{subplace-2}]] }
TexApi.setDescriptor { descriptor = "More Subplaces", description = [[\subparagraph{Subplace 3} \label{subplace-3}
\subparagraph{Subplace 4} \label{subplace-4}]] }
TexApi.newEntity { type = "species", label = "species", name = "Species" }
TexApi.setDescriptor { descriptor = "Subspecies", description = [[\label{subspecies}]] }

AddRef("some-npc", PrimaryRefs)

local out = TexApi.automatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\begin{itemize}]],
    [[\item \nameref{some-npc}]],
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

ResetEnvironment()

TexApi.newEntity{type = "npcs", label = "also-primary", name = "Also Primary"}
TexApi.setDescriptor{descriptor = "Sublabel 1", description = [[\label{sublabel-1}]]}
TexApi.setDescriptor{descriptor = "Some Paragraph", description = [[\subparagraph{Sublabel 2}\label{sublabel-2}]]}
AddRef("sublabel-1", MentionedRefs)
AddRef("sublabel-2", MentionedRefs)
AddRef("also-primary", PrimaryRefs)

TexApi.newEntity{type = "npcs", label = "not-primary", name = "Not Primary"}
TexApi.setDescriptor{descriptor = "Sublabel 3", description = [[\label{sublabel-3}]]}
TexApi.setDescriptor{descriptor = "Some ignored Paragraph", description = [[\subparagraph{Some ignored paragraph}\label{ignored-label}\subparagraph{Sublabel 4}\label{sublabel-4}]]}
AddRef("sublabel-3", MentionedRefs)
AddRef("sublabel-4", MentionedRefs)

local expected = {
    [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\begin{itemize}]],
    [[\item \nameref{also-primary}]],
    [[\item \nameref{sublabel-1}]],
    [[\item \nameref{sublabel-2}]],
    [[\end{itemize}]],
    [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]],
    [[\subsubsection{Also Primary}]],
    [[\label{also-primary}]],
    [[\paragraph{Some Paragraph}]],
    [[\subparagraph{Sublabel 2}\label{sublabel-2}]],
    [[\paragraph{Sublabel 1}]],
    [[\label{sublabel-1}]],
    [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]],
    [[\subparagraph{Sublabel 3}]],
    [[\label{sublabel-3}]],
    [[\hspace{1cm}]],
    [[\subparagraph{Sublabel 4}]],
    [[\label{sublabel-4}]],
    [[\hspace{1cm}]],
}

local out = TexApi.automatedChapters()

Assert("Only sublabel mentioned", expected, out)
