local function entitySetup(level)
    TexApi.newEntity { label = "species-1", category = "species", name = "species-1" }
    TexApi.setDescriptor { descriptor = "species-2", description = [[\label{species-2}
\paragraph{species-3}\label{species-3}
\subparagraph{species-4}\label{species-4}]] }
    TexApi.setAgeFactor(1)

    TexApi.newEntity { label = "char-1", category = "NPCs", name = "char-1" }
    TexApi.born { year = -15, event = "Born." }
    TexApi.setDescriptor { descriptor = "char-2", description = [[\label{char-2}
\paragraph{char-3}\label{char-3}
\subparagraph{char-4}\label{char-4}]] }

    TexApi.setSpecies("species-" .. level)
end

local function setup()
    TexApi.makeAllEntitiesPrimary()
    TexApi.setCurrentYear(0)
end

local function generateExpected(level)
    local expected = {}
    Append(expected, [[\chapter{NPCs}]])
    Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
    Append(expected, [[\begin{itemize}]])
    Append(expected, [[\item \nameref{char-1}]])
    Append(expected, [[\item \nameref{char-2}]])
    Append(expected, [[\item \nameref{char-3}]])
    Append(expected, [[\item \nameref{char-4}]])
    Append(expected, [[\end{itemize}]])
    Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(expected, [[\subsection{Char-1}]])
    Append(expected, [[\label{char-1}]])

    Append(expected, [[\subsubsection{]] .. CapFirst(Tr("appearance")) .. [[}]])
    Append(expected, [[\paragraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]])
    Append(expected, [[\nameref{species-]] .. level .. [[}, 15 ]] .. Tr("years_old") .. [[.]])

    Append(expected, [[\subsubsection{Char-2}]])
    Append(expected, [[\label{char-2}]])
    Append(expected, [[\paragraph{Char-3}]])
    Append(expected, [[\label{char-3}]])
    Append(expected, [[\subparagraph{Char-4}]])
    Append(expected, [[\label{char-4}]])

    Append(expected, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(expected, [[\begin{itemize}]])
    Append(expected, [[\item -15 (]] .. Tr("x_years_ago", { 15 }) .. [[):\\Born.]])
    Append(expected,
        [[\item -3 (]] ..
        Tr("x_years_ago", { 3 }) .. [[):\\ \nameref{char-1} ]] .. Tr("is") .. [[ ]] .. Tr("juvenile") ..
        [[.]])
    Append(expected, [[\end{itemize}]])

    Append(expected, [[\chapter{Species}]])
    Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Species}]])
    Append(expected, [[\begin{itemize}]])
    Append(expected, [[\item \nameref{species-1}]])
    Append(expected, [[\item \nameref{species-2}]])
    Append(expected, [[\item \nameref{species-3}]])
    Append(expected, [[\item \nameref{species-4}]])
    Append(expected, [[\end{itemize}]])
    Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(expected, [[\subsection{Species-1}]])
    Append(expected, [[\label{species-1}]])

    Append(expected, [[\subsubsection{Species-2}]])
    Append(expected, [[\label{species-2}]])
    Append(expected, [[\paragraph{Species-3}]])
    Append(expected, [[\label{species-3}]])
    Append(expected, [[\subparagraph{Species-4}]])
    Append(expected, [[\label{species-4}]])

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
    return expected
end

for level = 1, 4 do
    entitySetup(level)
    local expected = generateExpected(level)
    AssertAutomatedChapters("Entity with subentities and species-" .. level, expected, setup)
end
