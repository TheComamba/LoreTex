NewEntity("test-species", "species", nil, "Test Species")

NewEntity("test-npc", "npcs", nil, "Test NPC")
SetDescriptor(CurrentEntity(), "species", "test-species")
SetDescriptor(CurrentEntity(), "born", -20)

AddAllEntitiesToPrimaryRefs()

IsShowFuture = false
local out = AutomatedChapters()

local expected = {
    [[\chapter{]] .. Tr("characters") .. [[}]],
    [[\section*{]] .. Tr("all") .. [[ ]] .. Tr("characters") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-npc}]],
    [[\end{itemize}]],
    [[\section{]] .. Tr("npcs") .. [[}]],
    [[\subsection{]] .. Tr("in-whole-world") .. [[}]],
    [[\subsubsection{Test NPC}]],
    [[\label{test-npc}]],
    [[\paragraph{]] .. Tr("appearance") .. [[}]],
    [[\subparagraph{]] .. Tr("species-and-age") .. [[:}\nameref {test-species}, 20 ]] .. Tr("years-old") .. [[.]],
    [[\paragraph{]] .. Tr("history") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} -8 Vin (]] ..
        Tr("years-ago", { 8 }) .. [[): \nameref{test-npc} ]] .. Tr("is") .. [[ ]] .. Tr("juvenile") .. [[.]],
    [[\item{} 0 Vin (]] .. Tr("this-year") .. [[): \nameref{test-npc} ]] .. Tr("is") .. [[ ]] .. Tr("young") .. [[.]],
    [[\end{itemize}]],
    [[\chapter{]] .. Tr("species") .. [[}]],
    [[\section*{]] .. Tr("all") .. [[ ]] .. Tr("species") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{test-species}]],
    [[\end{itemize}]],
    [[\section{]] .. Tr("species") .. [[}]],
    [[\subsection{]] .. Tr("in-whole-world") .. [[}]],
    [[\subsubsection{Test Species}]],
    [[\label{test-species}]],
    [[\paragraph{]] .. Tr("lifestages") .. [[}]],
    [[\subparagraph{]] .. Tr("child") .. [[} 0-12 ]] .. Tr("years") .. [[
    \subparagraph{]] .. Tr("juvenile") .. [[} 12-20 ]] .. Tr("years") .. [[
    \subparagraph{]] .. Tr("young") .. [[} 20-30 ]] .. Tr("years") .. [[
    \subparagraph{]] .. Tr("adult") .. [[} 30-60 ]] .. Tr("years") .. [[
    \subparagraph{]] .. Tr("old") .. [[} 60-90 ]] .. Tr("years") .. [[
    \subparagraph{]] .. Tr("ancient") .. [[} 90+ ]] .. Tr("years") .. [[]]
}

Assert("npc-and-species", expected, out)
