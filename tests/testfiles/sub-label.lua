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

local function refSetup1()
    TexApi.makeEntityPrimary("some-npc")
    TexApi.addType { metatype = "characters", type = "npcs" }
end

local expected = {
    [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\begin{itemize}]],
    [[\item \nameref{some-npc}]],
    [[\end{itemize}]],
    [[\subsection{]] .. CapFirst(Tr("located_in")) .. [[ Subplace 1}]],
    [[\subsubsection{Some NPC}]],
    [[\label{some-npc}]],
    [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]],
    [[\subparagraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]],
    [[\nameref {subspecies}.]],
    [[\paragraph{Info 1}]],
    [[Refers to \nameref{subplace-2}.]],
    [[\paragraph{Info 2}]],
    [[Refers to \nameref{subplace-3}.]],
    [[\paragraph{Info 3}]],
    [[Refers to \nameref{subplace-4}.]],
    [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]],
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

AssertAutomatedChapters("Sublabel", expected, refSetup1)

TexApi.newEntity { type = "npcs", label = "also-primary", name = "Also Primary" }
TexApi.setDescriptor { descriptor = "Sublabel 1", description = [[\label{sublabel-1}]] }
TexApi.setDescriptor { descriptor = "Some Paragraph", description = [[\subparagraph{Sublabel 2}\label{sublabel-2}]] }

TexApi.newEntity { type = "npcs", label = "not-primary", name = "Not Primary" }
TexApi.setDescriptor { descriptor = "Sublabel 3", description = [[\label{sublabel-3}]] }
TexApi.setDescriptor { descriptor = "Some ignored Paragraph",
    description =
    [[\subparagraph{Some ignored paragraph}\label{ignored-label}\subparagraph{Sublabel 4}\label{sublabel-4}]] }

local function refSetup2()
    TexApi.mention("sublabel-1")
    TexApi.mention("sublabel-2")
    TexApi.makeEntityPrimary("also-primary")
    TexApi.mention("sublabel-3")
    TexApi.mention("sublabel-4")
    TexApi.addType { metatype = "characters", type = "npcs" }
end

local expected = {
    [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\begin{itemize}]],
    [[\item \nameref{also-primary}]],
    [[\item \nameref{sublabel-1}]],
    [[\item \nameref{sublabel-2}]],
    [[\end{itemize}]],
    [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]],
    [[\subsubsection{Also Primary}]],
    [[\label{also-primary}]],
    [[\paragraph{Some Paragraph}]],
    [[\subparagraph{Sublabel 2}]],
    [[\label{sublabel-2}]],
    [[\paragraph{Sublabel 1}]],
    [[\label{sublabel-1}]],
    [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]],
    [[\subparagraph{Sublabel 3}]],
    [[\label{sublabel-3}]],
    [[\hspace{1cm}]],
    [[\subparagraph{Sublabel 4}]],
    [[\label{sublabel-4}]],
    [[\hspace{1cm}]],
}

AssertAutomatedChapters("Only sublabel mentioned", expected, refSetup2)

TexApi.newEntity { type = "npcs", label = "some-npc", name = "Some NPC" }
TexApi.setDescriptor { descriptor = "Paragraph with just label", description = [[\label{sublabel}]] }
local paraWithoutLabel = {}
Append(paraWithoutLabel, [[\subparagraph{AA Subpara 1}]])
Append(paraWithoutLabel, [[\subparagraph{BB Subpara 2}]])
TexApi.setDescriptor { descriptor = "Paragraph with no label", description = table.concat(paraWithoutLabel) }
local paraWitLabeledSubs = {}
Append(paraWitLabeledSubs, [[\label{para-labeled-subs} Some content]])
Append(paraWitLabeledSubs, [[\subparagraph{CC Subpara 1} ]])
Append(paraWitLabeledSubs, [[\label{subpara-1}]])
Append(paraWitLabeledSubs, [[\subparagraph{DD Subpara 2}]])
Append(paraWitLabeledSubs, [[\label{subpara-2}]])
TexApi.setDescriptor { descriptor = "Labeled subparagraphs", description = table.concat(paraWitLabeledSubs, " ") }
local unusualPara = {}
Append(unusualPara, [[Some content but no label]])
Append(unusualPara, [[\subparagraph{EE Subpara without label}]])
Append(unusualPara, [[\subparagraph{FF Subpara with label}]])
Append(unusualPara, [[\label{subpara-with-label}]])
Append(unusualPara, [[\subparagraph{GG Again no label}]])
Append(unusualPara, [[But some miscelaneous content]])
TexApi.setDescriptor { descriptor = "Unusual paragraph", description = table.concat(unusualPara, " ") }

local function refSetup3()
    TexApi.makeEntityPrimary("some-npc")
    TexApi.addType { metatype = "characters", type = "npcs" }
end

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{subpara-1}]])
Append(expected, [[\item \nameref{subpara-2}]])
Append(expected, [[\item \nameref{subpara-with-label}]])
Append(expected, [[\item \nameref{para-labeled-subs}]])
Append(expected, [[\item \nameref{sublabel}]])
Append(expected, [[\item \nameref{some-npc}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsubsection{Some NPC}]])
Append(expected, [[\label{some-npc}]])
Append(expected, [[\paragraph{Labeled subparagraphs}]])
Append(expected, paraWitLabeledSubs)
Append(expected, [[\paragraph{Paragraph with just label}]])
Append(expected, [[\label{sublabel}]])
Append(expected, [[\paragraph{Paragraph with no label}]])
Append(expected, paraWithoutLabel)
Append(expected, [[\paragraph{Unusual paragraph}]])
Append(expected, unusualPara)

AssertAutomatedChapters("Subparagraphs with and without labels", expected, refSetup3)

TexApi.newEntity { type = "places", label = "place-1", name = "Place 1" }
TexApi.setDescriptor { descriptor = "Appears Twice", description = [[\subparagraph{One}\label{one}]] }
TexApi.newEntity { type = "places", label = "place-2", name = "Place 2" }
TexApi.setDescriptor { descriptor = "Appears Twice", description = [[\subparagraph{Two}\label{two}]] }

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{one}]])
Append(expected, [[\item \nameref{place-1}]])
Append(expected, [[\item \nameref{place-2}]])
Append(expected, [[\item \nameref{two}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsubsection{Place 1}]])
Append(expected, [[\label{place-1}]])
Append(expected, [[\paragraph{Appears Twice}]])
Append(expected, [[\subparagraph{One}]])
Append(expected, [[\label{one}]])
Append(expected, [[\subsubsection{Place 2}]])
Append(expected, [[\label{place-2}]])
Append(expected, [[\paragraph{Appears Twice}]])
Append(expected, [[\subparagraph{Two}]])
Append(expected, [[\label{two}]])

local function refSetup4()
    TexApi.makeAllEntitiesPrimary()
    TexApi.addType { metatype = "places", type = "places" }
end

AssertAutomatedChapters("Unlabeled paragraph with labeled subpara appears twice", expected, refSetup4)
