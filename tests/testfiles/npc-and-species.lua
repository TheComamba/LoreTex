for key, isAgingDefined in pairs({ false, true }) do
    TexApi.setCurrentYear(0)

    TexApi.newEntity { type = "species", label = "test-species", name = "Test Species" }
    if isAgingDefined then
        TexApi.setAgeFactor(1)
    end

    TexApi.newEntity { type = "NPCs", label = "test-npc", name = "Test NPC" }
    TexApi.setSpecies("test-species")
    TexApi.born { year = -20, event = "Birth." }

    local expected = {}
    Append(expected, [[\chapter{NPCs}]])
    Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
    Append(expected, [[\begin{itemize}]])
    Append(expected, [[\item \nameref{test-npc}]])
    Append(expected, [[\end{itemize}]])
    Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(expected, [[\subsection{Test NPC}]])
    Append(expected, [[\label{test-npc}]])
    Append(expected, [[\subsubsection{]] .. CapFirst(Tr("appearance")) .. [[}]])
    Append(expected, [[\paragraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]])
    Append(expected, [[\nameref {test-species}, 20 ]] .. Tr("years_old") .. [[.]])
    Append(expected, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(expected, [[\begin{itemize}]])
    Append(expected, [[\item -20 (]] .. Tr("x_years_ago", { 20 }) .. [[):\\Birth.]])
    if isAgingDefined then
        Append(expected, [[\item -8 (]] ..
            Tr("x_years_ago", { 8 }) .. [[):\\ \nameref{test-npc} ]] .. Tr("is") .. [[ ]] .. Tr("juvenile") .. [[.]])
        Append(expected,
            [[\item 0 (]] .. Tr("this_year") .. [[):\\ \nameref{test-npc} ]] .. Tr("is") .. [[ ]] .. Tr("young") .. [[.]])
    end
    Append(expected, [[\end{itemize}]])
    Append(expected, [[\chapter{Species}]])
    Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Species}]])
    Append(expected, [[\begin{itemize}]])
    Append(expected, [[\item \nameref{test-species}]])
    Append(expected, [[\end{itemize}]])
    Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(expected, [[\subsection{Test Species}]])
    Append(expected, [[\label{test-species}]])
    if isAgingDefined then
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
    end

    local function setup()
        TexApi.makeAllEntitiesPrimary()
    end

    local name = { "Npc with species, aging " }
    if not isAgingDefined then
        Append(name, "not ")
    end
    Append(name, "defined")
    AssertAutomatedChapters(table.concat(name), expected, setup)
end
