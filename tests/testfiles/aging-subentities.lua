TexApi.newEntity { label = "char", type = "NPCs", name = "char" }
TexApi.born { year = -15, event = "Born." }
TexApi.setSpecies("species")
TexApi.setDescriptor { descriptor = "subchar", description = [[\paragraph{subsubchar}\label{subsubchar}
\paragraph{subsubsubchar}\label{subsubsubchar}]] }

TexApi.newEntity { label = "species", type = "species", name = "species" }
TexApi.setDescriptor { descriptor = "subspecies", description = [[\paragraph{subsubspecies}\label{subsubspecies}
\subparagraph{subsubsubspecies}\label{subsubsubspecies}]] }
TexApi.setAgeFactor(1)

local function setup()
    TexApi.makeAllEntitiesPrimary()
    TexApi.setCurrentYear(0)
    TexApi.addType { metatype = "characters", type = "NPCs" }
    TexApi.addType { metatype = "peoples", type = "species" }
end

local expected = {}
Append(expected, [[\chapter{NPCs}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{char}]])
Append(expected, [[\item \nameref{subsubchar}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsection{char}]])
Append(expected, [[\label{char}]])
Append(expected, [[\subsubsection{]] .. CapFirst(Tr("appearance")) .. [[}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]])
Append(expected, [[\nameref{species}, 15 ]] .. Tr("years_old") .. [[.]])
Append(expected, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item -15 (]] .. Tr("x_years_ago", { 15 }) .. [[):\\Born.]])
Append(expected,
    [[\item -3 (]] .. Tr("x_years_ago", { 3 }) .. [[):\\ \nameref{char} ]] .. Tr("is") .. [[ ]] .. Tr("juvenile") ..
    [[.]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsubsection{Subchar}]])
Append(expected, [[\paragraph{Subsubchar}]])
Append(expected, [[\label{subsubchar}]])

Append(expected, [[\chapter{Species}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Species}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{species}]])
Append(expected, [[\item \nameref{subsubspecies}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsection{species}]])
Append(expected, [[\label{species}]])
Append(expected, [[\subsubsection{]] .. CapFirst(Tr("lifestages")) .. [[}]])
Append(expected, [[\paragraph{\LoreTexSort{1}]] .. CapFirst(Tr("child")) .. [[}]])
Append(expected, [[0-12 ]] .. Tr("years"))
Append(expected, [[\paragraph{\LoreTexSort{2}]] .. CapFirst(Tr("juvenile")) .. [[}]])
Append(expected, [[12-20 ]] .. Tr("years"))
Append(expected, [[\paragraph{\LoreTexSort{3}]] .. CapFirst(Tr("young")) .. [[}]])
Append(expected, [[20-30 ]] .. Tr("years"))
Append(expected, [[\paragraph{\LoreTexSort{4}]] .. CapFirst(Tr("adult")) .. [[}]])
Append(expected, [[30-60 ]] .. Tr("years"))
Append(expected, [[\paragraph{\LoreTexSort{5}]] .. CapFirst(Tr("old")) .. [[}]])
Append(expected, [[60-90 ]] .. Tr("years"))
Append(expected, [[\paragraph{\LoreTexSort{6}]] .. CapFirst(Tr("ancient")) .. [[}]])
Append(expected, [[90+ ]] .. Tr("years"))
Append(expected, [[\subsubsection{Subspecies}]])
Append(expected, [[\paragraph{Subsubspecies}]])
Append(expected, [[\label{subsubspecies}]])

AssertAutomatedChapters("Entity with subentities and age", expected, setup)
