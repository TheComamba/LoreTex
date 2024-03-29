TexApi.newEntity { category = "NPCs", label = "primary-npc", name = "Primary NPC" }
TexApi.setDescriptor { descriptor = "Description", description = [[Different than \nameref{other-npc}.]] }
TexApi.addParent { parentLabel = "some-organisation" }
TexApi.newEntity { category = "NPCs", label = "mentioned-npc", name = "Mentioned NPC" }
TexApi.newEntity { category = "NPCs", label = "other-npc", name = "Other NPC" }
TexApi.newEntity { category = "NPCs", label = "not-mentioned-npc", name = "Not mentioned NPC" }
TexApi.newEntity { category = "other", label = "some-organisation", name = "Some Organisation" }

local function setup()
    TexApi.showSecrets()
    TexApi.makeEntityPrimary("primary-npc")
    TexApi.mention("mentioned-npc")
end

local expected = {}
Append(expected, [[\chapter{NPCs}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{primary-npc}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsection{Primary NPC}]])
Append(expected, [[\label{primary-npc}]])
Append(expected, [[\subsubsection{]] .. CapFirst(Tr("affiliations")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{some-organisation}.]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsubsection{Description}]])
Append(expected, [[Different than \nameref{other-npc}.]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])
Append(expected, [[\subparagraph{Mentioned NPC}]])
Append(expected, [[\label{mentioned-npc}]])
Append(expected, [[\hspace{1cm}]])
Append(expected, [[\subparagraph{Other NPC}]])
Append(expected, [[\label{other-npc}]])
Append(expected, [[\hspace{1cm}]])
Append(expected, [[\subparagraph{Some Organisation}]])
Append(expected, [[\label{some-organisation}]])
Append(expected, [[\hspace{1cm}]])

AssertAutomatedChapters("mentioned-refs", expected, setup)
