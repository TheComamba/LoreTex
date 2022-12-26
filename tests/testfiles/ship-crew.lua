TexApi.newEntity { type = "places", label = "ocean", name = "Ocean" }

TexApi.newEntity { type = "vehicles", label = "aurora", name = "Aurora" }
TexApi.setLocation("ocean")

SetScopedVariable("DefaultLocation", GetMutableEntityFromAll("aurora"))

TexApi.newEntity { type = "npcs", label = "haldora", name = "Haldora" }
TexApi.addParent { parentLabel = "aurora", relationship = "Captain" }

TexApi.newEntity { type = "npcs", label = "balagog", name = "Balagog" }
TexApi.addParent { parentLabel = "aurora", relationship = "First Mate" }
TexApi.addParent { parentLabel = "aurora", relationship = "Cook" }

TexApi.newEntity { type = "npcs", label = "cuen", name = "Cuen" }
TexApi.addParent { parentLabel = "aurora" }

AddAllEntitiesToPrimaryRefs()

local function generateCrewMember(label, roles)
    local out = {}
    Append(out, [[\subsubsection{]] .. CapFirst(label) .. [[}]])
    Append(out, [[\label{]] .. label .. [[}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    for key, role in pairs(roles) do
        Append(out, [[\item ]] .. role .. [[ ]] .. Tr("of") .. [[ \nameref{aurora}.]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{balagog}]])
Append(expected, [[\item \nameref{cuen}]])
Append(expected, [[\item \nameref{haldora}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Ocean - Aurora}]])
Append(expected, generateCrewMember("balagog", { "Cook", "First Mate" }))
Append(expected, generateCrewMember("cuen", { CapFirst(Tr("member")) }))
Append(expected, generateCrewMember("haldora", { "Captain" }))

Append(expected, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{ocean}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection{Ocean}]])
Append(expected, [[\label{ocean}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("vehicles") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{aurora}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("things")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("vehicles")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("vehicles")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{aurora}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Ocean}]])
Append(expected, [[\subsubsection{Aurora}]])
Append(expected, [[\label{aurora}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("npcs") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{balagog} (Cook, First Mate)]])
Append(expected, [[\item \nameref{cuen}]])
Append(expected, [[\item \nameref{haldora} (Captain)]])
Append(expected, [[\end{itemize}]])

local out = TexApi.automatedChapters()
Assert("Example Ship Crew", expected, out)
