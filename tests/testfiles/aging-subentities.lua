TexApi.newEntity { label = "char", type = "npcs", name = "char" }
TexApi.born { year = -15, event = "Born." }
TexApi.setSpecies("species")
TexApi.setDescriptor { descriptor = "subchar", description = [[\subparagraph{subsubchar}\label{subsubchar}]] }

TexApi.newEntity { label = "species", type = "species", name = "species" }
TexApi.setDescriptor { descriptor = "subspecies", description = [[\subparagraph{subsubspecies}\label{subsubspecies}]] }
TexApi.setAgeFactor(1)

local function setup()
    TexApi.makeAllEntitiesPrimary()
    TexApi.setCurrentYear(0)
    TexApi.addType { metatype = "characters", type = "npcs" }
    TexApi.addType { metatype = "peoples", type = "species" }
end

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{char}]])
Append(expected, [[\item \nameref{subsubchar}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsubsection{char}]])
Append(expected, [[\label{char}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
Append(expected, [[\subparagraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]])
Append(expected, [[\nameref{species}, 15 ]] .. Tr("years_old") .. [[.]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item -15 (]] .. Tr("x_years_ago", { 15 }) .. [[):\\Born.]])
Append(expected,
    [[\item -3 (]] .. Tr("x_years_ago", { 3 }) .. [[):\\ \nameref{char} ]] .. Tr("is") .. [[ ]] .. Tr("juvenile") ..
    [[.]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\paragraph{Subchar}]])
Append(expected, [[\subparagraph{Subsubchar}]])
Append(expected, [[\label{subsubchar}]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("peoples")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("species")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. CapFirst(Tr("species")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{species}]])
Append(expected, [[\item \nameref{subsubspecies}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsubsection{species}]])
Append(expected, [[\label{species}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("lifestages")) .. [[}]])
Append(expected, [[\subparagraph{\LoreTexSort{1}]] .. CapFirst(Tr("child")) .. [[}]])
Append(expected, [[0-12 ]] .. Tr("years"))
Append(expected, [[\subparagraph{\LoreTexSort{2}]] .. CapFirst(Tr("juvenile")) .. [[}]])
Append(expected, [[12-20 ]] .. Tr("years"))
Append(expected, [[\subparagraph{\LoreTexSort{3}]] .. CapFirst(Tr("young")) .. [[}]])
Append(expected, [[20-30 ]] .. Tr("years"))
Append(expected, [[\subparagraph{\LoreTexSort{4}]] .. CapFirst(Tr("adult")) .. [[}]])
Append(expected, [[30-60 ]] .. Tr("years"))
Append(expected, [[\subparagraph{\LoreTexSort{5}]] .. CapFirst(Tr("old")) .. [[}]])
Append(expected, [[60-90 ]] .. Tr("years"))
Append(expected, [[\subparagraph{\LoreTexSort{6}]] .. CapFirst(Tr("ancient")) .. [[}]])
Append(expected, [[90+ ]] .. Tr("years"))
Append(expected, [[\paragraph{Subspecies}]])
Append(expected, [[\subparagraph{Subsubspecies}]])
Append(expected, [[\label{subsubspecies}]])

AssertAutomatedChapters("Entity with subentities and age", expected, setup)
