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

TexApi.makeEntityPrimary("some-npc")

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

Assert("Sublabel", expected, out)

ResetState()

TexApi.newEntity { type = "npcs", label = "also-primary", name = "Also Primary" }
TexApi.setDescriptor { descriptor = "Sublabel 1", description = [[\label{sublabel-1}]] }
TexApi.setDescriptor { descriptor = "Some Paragraph", description = [[\subparagraph{Sublabel 2}\label{sublabel-2}]] }
TexApi.mention("sublabel-1")
TexApi.mention("sublabel-2")
TexApi.makeEntityPrimary("also-primary")

TexApi.newEntity { type = "npcs", label = "not-primary", name = "Not Primary" }
TexApi.setDescriptor { descriptor = "Sublabel 3", description = [[\label{sublabel-3}]] }
TexApi.setDescriptor { descriptor = "Some ignored Paragraph",
    description = [[\subparagraph{Some ignored paragraph}\label{ignored-label}\subparagraph{Sublabel 4}\label{sublabel-4}]] }
TexApi.mention("sublabel-3")
TexApi.mention("sublabel-4")

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

ResetState()

TexApi.newEntity { type = "npcs", label = "some-npc", name = "Some NPC" }
TexApi.setDescriptor { descriptor = "Paragraph with just label", description = [[\label{sublabel}]] }
local paraWithoutLabel = {}
Append(paraWithoutLabel, [[\subparagraph{Subpara 1}]])
Append(paraWithoutLabel, [[\subparagraph{Subpara 2}]])
TexApi.setDescriptor { descriptor = "Paragraph with no label", description = table.concat(paraWithoutLabel, " ") }
local paraWitLabeledSubs = {}
Append(paraWitLabeledSubs, [[\label{para-labeled-subs}]])
Append(paraWitLabeledSubs, [[Some content]])
Append(paraWitLabeledSubs, [[\subparagraph{Subpara 1}]])
Append(paraWitLabeledSubs, [[\label{subpara-1}]])
Append(paraWitLabeledSubs, [[\subparagraph{Subpara 2}]])
Append(paraWitLabeledSubs, [[\label{subpara-2}]])
TexApi.setDescriptor { descriptor = "Labeled subparagraphs", description = table.concat(paraWitLabeledSubs, " ") }
local unusualPara = {}
Append(unusualPara, [[Some content but no label]])
Append(unusualPara, [[\subparagraph{Subpara without label}]])
Append(unusualPara, [[\subparagraph{Subpara with label}]])
Append(unusualPara, [[\label{subpara-with-label}]])
Append(unusualPara, [[\subparagraph{Another subparagraph without label}]])
TexApi.setDescriptor { descriptor = "Unusual paragraph", description = table.concat(unusualPara, " ") }
TexApi.makeEntityPrimary("some-npc")

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{para-labeled-subs}]])
Append(expected, [[\item \nameref{sublabel}]])
Append(expected, [[\item \nameref{some-npc}]])
Append(expected, [[\item \nameref{subpara-1}]])
Append(expected, [[\item \nameref{subpara-2}]])
Append(expected, [[\item \nameref{subpara-with-label}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection{Some NPC}]])
Append(expected, [[\label{some-npc}]])
Append(expected, [[\paragraph{Labeled subparagraphs}]])
Append(expected, table.concat(paraWitLabeledSubs, " "))
Append(expected, [[\paragraph{Paragraph with just label}]])
Append(expected, [[\label{sublabel}]])
Append(expected, [[\paragraph{Paragraph with no label}]])
Append(expected, table.concat(paraWithoutLabel, " "))
Append(expected, [[\paragraph{Unusual paragraph}]])
Append(expected, table.concat(unusualPara, " "))

local out = TexApi.automatedChapters()

Assert("Subparagraphs with and without labels", expected, out)
