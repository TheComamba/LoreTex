NewEntity("orga", "organisation", nil, "Orga")
local orga = CurrentEntity()
NewEntity("place-1", "place", nil, "Place 1")
AddAssociation(CurrentEntity(), "orga")
NewEntity("place-2", "place", nil, "Place 2")
local place2 = CurrentEntity()
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
    [[\item{} Mitglied der \nameref{orga}.]],
    [[\end{itemize}]],
    [[\subsubsection{Place 2}]],
    [[\label{place-2}]],
    [[\paragraph{Zusammenschlüsse}]],
    [[\begin{itemize}]],
    [[\item{} Hometown der \nameref{orga}.]],
    [[\end{itemize}]],
    [[\chapter{Zusammenschlüsse}]],
    [[\section*{Alle Zusammenschlüsse}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{orga}]],
    [[\end{itemize}]],
    [[\section{Organisationen}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Orga}]],
    [[\label{orga}]],
    [[\paragraph{Orte}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2} (Hometown)]],
    [[\end{itemize}]]
}

Assert("entities-with-associations", expected, out)

NewEntity("place-3", "place", nil, "Place 3")
NewEntity("place-4", "place", nil, "Place 4")
SetDescriptor(orga, "location", "place-3")
SetDescriptor(place2, "location", "place-4")


out = AutomatedChapters()

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
    [[\item{} Mitglied der \nameref{orga}.]],
    [[\end{itemize}]],
    [[\subsection{In Place 4}]],
    [[\subsubsection{Place 2}]],
    [[\label{place-2}]],
    [[\paragraph{Zusammenschlüsse}]],
    [[\begin{itemize}]],
    [[\item{} Hometown der \nameref{orga}.]],
    [[\end{itemize}]],
    [[\chapter{Zusammenschlüsse}]],
    [[\section*{Alle Zusammenschlüsse}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{orga}]],
    [[\end{itemize}]],
    [[\section{Organisationen}]],
    [[\subsection{In Place 3}]],
    [[\subsubsection{Orga}]],
    [[\label{orga}]],
    [[\paragraph{Orte}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2} (Hometown, in \nameref{place-4})]],
    [[\end{itemize}]],
    [[\chapter{Nur erwähnt}]],
    [[\subparagraph{Place 4}]],
    [[\label{place-4}]],
    [[\hspace{1cm}]]
}

Assert("entities-with-associations-and-locations", expected, out)
