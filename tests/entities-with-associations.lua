NewEntity("orga", "organisation", nil, "Orga")
NewEntity("place-1", "place", nil, "Place 1")
AddAssociation(CurrentEntity(), "orga")
NewEntity("place-2", "place", nil, "Place 2")
AddAssociation(CurrentEntity(), "orga", "Hometown")

AddAllEntitiesToPrimaryRefs()
local out = AutomatedChapters()

local expected = {
    [[\chapter{Orte}]],
    [[\section*{Alle Orte}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2}]],
    [[\end{itemize}]],
    [[\section{Orte}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Place 1}]],
    [[\label{place-1}]],
    [[\paragraph{Zusammenschlüsse}]],
    [[\begin{itemize}]],
    [[\item{} Mitglied der \nameref{orga}]],
    [[\end{itemize}]],
    [[\subsubsection{Place 2}]],
    [[\label{place-2}]],
    [[\paragraph{Zusammenschlüsse}]],
    [[\begin{itemize}]],
    [[\item{} Hometown der \nameref{orga}]],
    [[\end{itemize}]],
    [[\chapter{Zusammenschlüsse}]],
    [[\section*{Alle Organisationen}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{orga}]],
    [[\end{itemize}]],
    [[\section{Organisationen}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Orga}]],
    [[\paragraph{Mitglieder}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2}]],
    [[\end{itemize}]]
}

Assert("entities-with-associations", expected, out)

NewEntity("place-3", "place", nil, "Place 3")
NewEntity("place-4", "place", nil, "Place 4")
SetDescriptor(GetEntity("orga", AllEntities), "location", "place-3")
SetDescriptor(GetEntity("place-2", AllEntities), "location", "place-4")


out = AutomatedChapters()

Assert("entities-with-associations-and-locations", expected, out)