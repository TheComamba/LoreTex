TexApi.setCurrentYear(0)

TexApi.newEntity { type = "species", label = "test-species", name = "Test Species" }

TexApi.newEntity { type = "npcs", label = "test-npc", name = "Test NPC" }
SetSpecies(CurrentEntity(), "test-species")
SetProtectedField(CurrentEntity(), "born", -20)

AddAllEntitiesToPrimaryRefs()

IsShowFuture = false
local out = TexApi.automatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]],
    [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]],
    [[\begin{itemize}]],
    [[\item \nameref{test-npc}]],
    [[\end{itemize}]],
    [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]],
    [[\subsubsection{Test NPC}]],
    [[\label{test-npc}]],
    [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]],
    [[\subparagraph{]] ..
        CapFirst(Tr("species-and-age")) .. [[:}\nameref {test-species}, 20 ]] .. Tr("years-old") .. [[.]],
    [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]],
    [[\begin{itemize}]],
    [[\item -8 (]] ..
        Tr("years-ago", { 8 }) .. [[):\\ \nameref{test-npc} ]] .. Tr("is") .. [[ ]] .. Tr("juvenile") .. [[.]],
    [[\item 0 (]] .. Tr("this-year") .. [[):\\ \nameref{test-npc} ]] .. Tr("is") .. [[ ]] .. Tr("young") .. [[.]],
    [[\end{itemize}]],
    [[\chapter{]] .. CapFirst(Tr("peoples")) .. [[}]],
    [[\section{]] .. CapFirst(Tr("species")) .. [[}]],
    [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("species")) .. [[}]],
    [[\begin{itemize}]],
    [[\item \nameref{test-species}]],
    [[\end{itemize}]],
    [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]],
    [[\subsubsection{Test Species}]],
    [[\label{test-species}]],
    [[\paragraph{]] .. CapFirst(Tr("lifestages")) .. [[}]],
    [[\subparagraph{]] .. CapFirst(Tr("child")) .. [[} 0-12 ]] .. Tr("years") .. [[
    \subparagraph{]] .. CapFirst(Tr("juvenile")) .. [[} 12-20 ]] .. Tr("years") .. [[
    \subparagraph{]] .. CapFirst(Tr("young")) .. [[} 20-30 ]] .. Tr("years") .. [[
    \subparagraph{]] .. CapFirst(Tr("adult")) .. [[} 30-60 ]] .. Tr("years") .. [[
    \subparagraph{]] .. CapFirst(Tr("old")) .. [[} 60-90 ]] .. Tr("years") .. [[
    \subparagraph{]] .. CapFirst(Tr("ancient")) .. [[} 90+ ]] .. Tr("years") .. [[]]
}

Assert("npc-and-species", expected, out)
