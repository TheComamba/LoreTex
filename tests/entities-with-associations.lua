NewEntity("orga", "organisations", nil, "Orga")
local orga = CurrentEntity()
NewEntity("place-1", "places", nil, "Place 1")
AddAssociation(CurrentEntity(), "orga")
NewEntity("place-2", "places", nil, "Place 2")
local place2 = CurrentEntity()
AddAssociation(CurrentEntity(), "orga", "Hometown")

AddAllEntitiesToPrimaryRefs()
local out = AutomatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. " " .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2}]],
    [[\end{itemize}]],
    [[\section{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]],
    [[\subsubsection{Place 1}]],
    [[\label{place-1}]],
    [[\paragraph{]] .. CapFirst(Tr("associations")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{orga}.]],
    [[\end{itemize}]],
    [[\subsubsection{Place 2}]],
    [[\label{place-2}]],
    [[\paragraph{]] .. CapFirst(Tr("associations")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} Hometown ]] .. Tr("of") .. [[ \nameref{orga}.]],
    [[\end{itemize}]],
    [[\chapter{]] .. CapFirst(Tr("associations")) .. [[}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("associations")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{orga}]],
    [[\end{itemize}]],
    [[\section{]] .. CapFirst(Tr("organisations")) .. [[}]],
    [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]],
    [[\subsubsection{Orga}]],
    [[\label{orga}]],
    [[\paragraph{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2} (Hometown)]],
    [[\end{itemize}]]
}

Assert("entities-with-associations", expected, out)

NewEntity("place-3", "places", nil, "Place 3")
NewEntity("place-4", "places", nil, "Place 4")
SetDescriptor(orga, "location", "place-3")
SetDescriptor(place2, "location", "place-4")


out = AutomatedChapters()

local expected = {
    [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2}]],
    [[\end{itemize}]],
    [[\section{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]],
    [[\subsubsection{Place 1}]],
    [[\label{place-1}]],
    [[\paragraph{]] .. CapFirst(Tr("associations")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{orga}.]],
    [[\end{itemize}]],
    [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Place 4}]],
    [[\subsubsection{Place 2}]],
    [[\label{place-2}]],
    [[\paragraph{]] .. CapFirst(Tr("associations")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} Hometown ]] .. Tr("of") .. [[ \nameref{orga}.]],
    [[\end{itemize}]],
    [[\chapter{]] .. CapFirst(Tr("associations")) .. [[}]],
    [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("associations")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{orga}]],
    [[\end{itemize}]],
    [[\section{]] .. CapFirst(Tr("organisations")) .. [[}]],
    [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Place 3}]],
    [[\subsubsection{Orga}]],
    [[\label{orga}]],
    [[\paragraph{]] .. CapFirst(Tr("places")) .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2} (Hometown, ]] .. Tr("in") .. [[ \nameref{place-4})]],
    [[\end{itemize}]],
    [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]],
    [[\subparagraph{Place 4}]],
    [[\label{place-4}]],
    [[\hspace{1cm}]]
}

Assert("entities-with-associations-and-locations", expected, out)
