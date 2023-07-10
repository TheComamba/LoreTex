TexApi.newEntity { type = "places", label = "ocean", name = "Ocean" }

TexApi.newEntity { type = "ships", label = "aurora", name = "Aurora" }
TexApi.setLocation("ocean")

SetScopedVariable("DefaultLocation", GetMutableEntityFromAll("aurora"))

TexApi.newEntity { type = "NPCs", label = "haldora", name = "Haldora" }
TexApi.addParent { parentLabel = "aurora", relationship = "Captain" }

TexApi.newEntity { type = "NPCs", label = "balagog", name = "Balagog" }
TexApi.addParent { parentLabel = "aurora", relationship = "First Mate" }
TexApi.addParent { parentLabel = "aurora", relationship = "Cook" }

TexApi.newEntity { type = "NPCs", label = "cuen", name = "Cuen" }
TexApi.addParent { parentLabel = "aurora" }

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

TexApi.addTranslation { language = "english", key = "ships", translation = "ships" }

local expected = {}
Append(expected, [[\chapter{Characters}]])
Append(expected, [[\section{NPCs}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{balagog}]])
Append(expected, [[\item \nameref{cuen}]])
Append(expected, [[\item \nameref{haldora}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("located_in")) .. [[ Ocean - Aurora}]])
Append(expected, generateCrewMember("balagog", { "Cook", "First Mate" }))
Append(expected, generateCrewMember("cuen", { CapFirst(Tr("member")) }))
Append(expected, generateCrewMember("haldora", { "Captain" }))

Append(expected, [[\chapter{Other}]])
Append(expected, [[\section{Ships}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ Ships}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{aurora}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("located_in")) .. [[ Ocean}]])
Append(expected, [[\subsubsection{Aurora}]])
Append(expected, [[\label{aurora}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ NPCs}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{balagog} (Cook, First Mate)]])
Append(expected, [[\item \nameref{cuen}]])
Append(expected, [[\item \nameref{haldora} (Captain)]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\chapter{Places}]])
Append(expected, [[\section{Places}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ Places}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{ocean}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsubsection{Ocean}]])
Append(expected, [[\label{ocean}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ships}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{aurora}]])
Append(expected, [[\end{itemize}]])

local function setup()
    TexApi.makeAllEntitiesPrimary()
    TexApi.addType { metatype = "other", type = "ships" }
    TexApi.addType { metatype = "characters", type = "NPCs" }
    TexApi.addType { metatype = "places", type = "places" }
end

AssertAutomatedChapters("Example Ship Crew", expected, setup)
