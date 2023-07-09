TexApi.newEntity { type = "npcs", label = "primary-npc", name = "Primary NPC" }
TexApi.setDescriptor { descriptor = "Description", description = [[Different than \nameref{other-npc}.]] }
TexApi.addParent { parentLabel = "some-organisation" }
TexApi.newEntity { type = "npcs", label = "mentioned-npc", name = "Mentioned NPC" }
TexApi.newEntity { type = "npcs", label = "other-npc", name = "Other NPC" }
TexApi.newEntity { type = "npcs", label = "not-mentioned-npc", name = "Not mentioned NPC" }
TexApi.newEntity { type = "other", label = "some-organisation", name = "Some Organisation" }

local function refSetup()
    TexApi.makeEntityPrimary("primary-npc")
    TexApi.mention("mentioned-npc")
    TexApi.addType { metatype = "characters", type = "npcs" }
end

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{primary-npc}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection{Primary NPC}]])
Append(expected, [[\label{primary-npc}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{some-organisation}.]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\paragraph{Description}]])
Append(expected, [[Different than \nameref{other-npc}.]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
Append(expected, [[\subparagraph{Mentioned NPC}]])
Append(expected, [[\label{mentioned-npc}]])
Append(expected, [[\hspace{1cm}]])
Append(expected, [[\subparagraph{Other NPC}]])
Append(expected, [[\label{other-npc}]])
Append(expected, [[\hspace{1cm}]])
Append(expected, [[\subparagraph{Some Organisation}]])
Append(expected, [[\label{some-organisation}]])
Append(expected, [[\hspace{1cm}]])

AssertAutomatedChapters("mentioned-refs", expected, refSetup)
