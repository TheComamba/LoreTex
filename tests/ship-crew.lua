NewEntity("places", "ocean", "", "Ocean")

NewEntity("ships", "aurora", "", "Aurora")
SetLocation(CurrentEntity(), "ocean")

SetScopedVariable("DefaultLocation", "aurora")

NewEntity("npcs", "haldora", "", "Haldora")
AddParent(CurrentEntity(), "aurora", "Captain")

NewEntity("npcs", "balagog", "", "Balagog")
AddParent(CurrentEntity(), "aurora", "Cook")

NewEntity("npcs", "cuen", "", "Cuen")
AddParent(CurrentEntity(), "aurora")

AddAllEntitiesToPrimaryRefs()

local function generateCrewMember(label, role)
    if role == nil then 
        role = CapFirst(Tr("member"))
    end
    local out = {}
    Append(out, [[\subsubsection{]] .. CapFirst(label).. [[}]])
    Append(out, [[\label{]] .. label.. [[}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliations")).. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} ]] .. role..[[ ]] .. Tr("of") .. [[ \nameref{aurora}.]])
    Append(out, [[\end{itemize}]])
    return out
end

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")).. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")).. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")).. [[ ]] .. CapFirst(Tr("npcs")).. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{balagog}]])
Append(expected, [[\item{} \nameref{cuen}]])
Append(expected, [[\item{} \nameref{haldora}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in")).. [[ Ocean - Aurora}]])
Append(expected, generateCrewMember("balagog", "Cook"))
Append(expected, generateCrewMember("cuen"))
Append(expected, generateCrewMember("haldora", "Captain"))


Append(expected, [[\chapter{]] .. CapFirst(Tr("items")).. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("ships")).. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")).. [[ ]] .. CapFirst(Tr("ships")).. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{aurora}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in")).. [[ Ocean}]])
Append(expected, [[\subsubsection{Aurora}]])
Append(expected, [[\label{aurora}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")).. [[ ]] .. Tr("npcs").. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{balagog} (Cook)]])
Append(expected, [[\item{} \nameref{cuen}]])
Append(expected, [[\item{} \nameref{haldora} (Captain).]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("places")).. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("places")).. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")).. [[ ]] .. CapFirst(Tr("places")).. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{ocean}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")).. [[}]])
Append(expected, [[\subsubsection{Ocean}]])
Append(expected, [[\label{ocean}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")).. [[ ]] .. Tr("ships").. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{aurora}]])
Append(expected, [[\end{itemize}]])

local out = AutomatedChapters()
Assert("Example Ship Crew", expected, out)