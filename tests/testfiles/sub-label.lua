TexApi.newEntity { type = "NPCs", label = "some-npc", name = "Some NPC" }
TexApi.setSpecies("subspecies")
TexApi.setLocation("subplace-1")
TexApi.setDescriptor { descriptor = "Info 1", description = [[Refers to \nameref{subplace-2}.]] }
TexApi.setDescriptor { descriptor = "Info 2", description = [[Refers to \nameref{subplace-3}.]] }
TexApi.setDescriptor { descriptor = "Info 3", description = [[Refers to \nameref{subplace-4}.]] }
TexApi.newEntity { type = "places", label = "place-1", name = "Place 1" }
TexApi.setDescriptor { descriptor = "Subplace 1", description = [[\label{subplace-1}]] }
TexApi.newEntity { type = "places", label = "place-2", name = "Place 2" }
TexApi.setDescriptor { descriptor = "Subplace 2", description = [[\label{subplace-2}]] }
TexApi.setDescriptor { descriptor = "More Subplaces", description = [[\paragraph{Subplace 3} \label{subplace-3}
\paragraph{Subplace 4} \label{subplace-4}]] }
TexApi.newEntity { type = "species", label = "species", name = "Species" }
TexApi.setDescriptor { descriptor = "Subspecies", description = [[\label{subspecies}]] }

local function refSetup1()
    TexApi.makeEntityPrimary("some-npc")
end

local expected = {
    [[\chapter{NPCs}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]],
    [[\begin{itemize}]],
    [[\item \nameref{some-npc}]],
    [[\end{itemize}]],
    [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Subplace 1}]],
    [[\subsection{Some NPC}]],
    [[\label{some-npc}]],
    [[\subsubsection{]] .. CapFirst(Tr("appearance")) .. [[}]],
    [[\paragraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]],
    [[\nameref {subspecies}.]],
    [[\subsubsection{Info 1}]],
    [[Refers to \nameref{subplace-2}.]],
    [[\subsubsection{Info 2}]],
    [[Refers to \nameref{subplace-3}.]],
    [[\subsubsection{Info 3}]],
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

TexApi.newEntity { type = "NPCs", label = "also-primary", name = "Also Primary" }
TexApi.setDescriptor { descriptor = "Sublabel 1", description = [[\label{sublabel-1}]] }
TexApi.setDescriptor { descriptor = "Some Paragraph", description = [[\paragraph{Sublabel 2}\label{sublabel-2}]] }

TexApi.newEntity { type = "NPCs", label = "not-primary", name = "Not Primary" }
TexApi.setDescriptor { descriptor = "Sublabel 3", description = [[\label{sublabel-3}]] }
TexApi.setDescriptor { descriptor = "Some ignored Paragraph",
    description =
    [[\paragraph{Some ignored paragraph}\label{ignored-label}\subparagraph{Sublabel 4}\label{sublabel-4}]] }

local function refSetup2()
    TexApi.mention("sublabel-1")
    TexApi.mention("sublabel-2")
    TexApi.makeEntityPrimary("also-primary")
    TexApi.mention("sublabel-3")
    TexApi.mention("sublabel-4")
end

local expected = {
    [[\chapter{NPCs}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]],
    [[\begin{itemize}]],
    [[\item \nameref{also-primary}]],
    [[\item \nameref{sublabel-1}]],
    [[\item \nameref{sublabel-2}]],
    [[\end{itemize}]],
    [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]],
    [[\subsection{Also Primary}]],
    [[\label{also-primary}]],
    [[\subsubsection{Some Paragraph}]],
    [[\paragraph{Sublabel 2}]],
    [[\label{sublabel-2}]],
    [[\subsubsection{Sublabel 1}]],
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

TexApi.newEntity { type = "NPCs", label = "some-npc", name = "Some NPC" }
TexApi.setDescriptor { descriptor = "Paragraph with just label", description = [[\label{sublabel}]] }
local paraWithoutLabel = {}
Append(paraWithoutLabel, [[\paragraph{AA Subpara 1}]])
Append(paraWithoutLabel, [[\paragraph{BB Subpara 2}]])
TexApi.setDescriptor { descriptor = "Paragraph with no label", description = table.concat(paraWithoutLabel) }
local paraWitLabeledSubs = {}
Append(paraWitLabeledSubs, [[\label{para-labeled-subs} Some content]])
Append(paraWitLabeledSubs, [[\paragraph{CC Subpara 1} ]])
Append(paraWitLabeledSubs, [[\label{subpara-1}]])
Append(paraWitLabeledSubs, [[\paragraph{DD Subpara 2}]])
Append(paraWitLabeledSubs, [[\label{subpara-2}]])
TexApi.setDescriptor { descriptor = "Labeled subparagraphs", description = table.concat(paraWitLabeledSubs, " ") }
local unusualPara = {}
Append(unusualPara, [[Some content but no label]])
Append(unusualPara, [[\paragraph{EE Subpara without label}]])
Append(unusualPara, [[\paragraph{FF Subpara with label}]])
Append(unusualPara, [[\label{subpara-with-label}]])
Append(unusualPara, [[\paragraph{GG Again no label}]])
Append(unusualPara, [[But some miscelaneous content]])
TexApi.setDescriptor { descriptor = "Unusual paragraph", description = table.concat(unusualPara, " ") }

local function refSetup3()
    TexApi.makeEntityPrimary("some-npc")
end

local expected = {}
Append(expected, [[\chapter{NPCs}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{subpara-1}]])
Append(expected, [[\item \nameref{subpara-2}]])
Append(expected, [[\item \nameref{subpara-with-label}]])
Append(expected, [[\item \nameref{para-labeled-subs}]])
Append(expected, [[\item \nameref{sublabel}]])
Append(expected, [[\item \nameref{some-npc}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsection{Some NPC}]])
Append(expected, [[\label{some-npc}]])
Append(expected, [[\subsubsection{Labeled subparagraphs}]])
Append(expected, paraWitLabeledSubs)
Append(expected, [[\subsubsection{Paragraph with just label}]])
Append(expected, [[\label{sublabel}]])
Append(expected, [[\subsubsection{Paragraph with no label}]])
Append(expected, paraWithoutLabel)
Append(expected, [[\subsubsection{Unusual paragraph}]])
Append(expected, unusualPara)

AssertAutomatedChapters("Subparagraphs with and without labels", expected, refSetup3)

TexApi.newEntity { type = "places", label = "place-1", name = "Place 1" }
TexApi.setDescriptor { descriptor = "Appears Twice", description = [[\paragraph{One}\label{one}]] }
TexApi.newEntity { type = "places", label = "place-2", name = "Place 2" }
TexApi.setDescriptor { descriptor = "Appears Twice", description = [[\paragraph{Two}\label{two}]] }

local expected = {}
Append(expected, [[\chapter{Places}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Places}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{one}]])
Append(expected, [[\item \nameref{place-1}]])
Append(expected, [[\item \nameref{place-2}]])
Append(expected, [[\item \nameref{two}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsection{Place 1}]])
Append(expected, [[\label{place-1}]])
Append(expected, [[\subsubsection{Appears Twice}]])
Append(expected, [[\paragraph{One}]])
Append(expected, [[\label{one}]])
Append(expected, [[\subsection{Place 2}]])
Append(expected, [[\label{place-2}]])
Append(expected, [[\subsubsection{Appears Twice}]])
Append(expected, [[\paragraph{Two}]])
Append(expected, [[\label{two}]])

local function refSetup4()
    TexApi.makeAllEntitiesPrimary()
end

AssertAutomatedChapters("Unlabeled paragraph with labeled subpara appears twice", expected, refSetup4)
