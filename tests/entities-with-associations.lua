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
    [[\chapter{]] .. Tr("places") .. [[}]],
    [[\section*{]] .. Tr("all") .. " " .. Tr("places") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2}]],
    [[\end{itemize}]],
    [[\section{]] .. Tr("places") .. [[}]],
    [[\subsection{]] .. Tr("in-whole-world") .. [[}]],
    [[\subsubsection{Place 1}]],
    [[\label{place-1}]],
    [[\paragraph{]] .. Tr("associations") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} ]] .. Tr("member") .. [[ ]] .. Tr("of") .. [[ \nameref{orga}.]],
    [[\end{itemize}]],
    [[\subsubsection{Place 2}]],
    [[\label{place-2}]],
    [[\paragraph{]] .. Tr("associations") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} Hometown ]] .. Tr("of") .. [[ \nameref{orga}.]],
    [[\end{itemize}]],
    [[\chapter{]] .. Tr("associations") .. [[}]],
    [[\section*{]] .. Tr("all") .. [[ ]] .. Tr("associations") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{orga}]],
    [[\end{itemize}]],
    [[\section{]] .. Tr("organisations") .. [[}]],
    [[\subsection{]] .. Tr("in-whole-world") .. [[}]],
    [[\subsubsection{Orga}]],
    [[\label{orga}]],
    [[\paragraph{]] .. Tr("places") .. [[}]],
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
    [[\chapter{]] .. Tr("places") .. [[}]],
    [[\section*{]] .. Tr("all") .. [[ ]] .. Tr("places") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2}]],
    [[\end{itemize}]],
    [[\section{]] .. Tr("places") .. [[}]],
    [[\subsection{]] .. Tr("in-whole-world") .. [[}]],
    [[\subsubsection{Place 1}]],
    [[\label{place-1}]],
    [[\paragraph{]] .. Tr("associations") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} ]] .. Tr("member") .. [[ ]] .. Tr("of") .. [[ \nameref{orga}.]],
    [[\end{itemize}]],
    [[\subsection{In Place 4}]],
    [[\subsubsection{Place 2}]],
    [[\label{place-2}]],
    [[\paragraph{]] .. Tr("associations") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} Hometown ]] .. Tr("of") .. [[ \nameref{orga}.]],
    [[\end{itemize}]],
    [[\chapter{]] .. Tr("associations") .. [[}]],
    [[\section*{]] .. Tr("all") .. [[ ]] .. Tr("associations") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{orga}]],
    [[\end{itemize}]],
    [[\section{]] .. Tr("organisations") .. [[}]],
    [[\subsection{In Place 3}]],
    [[\subsubsection{Orga}]],
    [[\label{orga}]],
    [[\paragraph{]] .. Tr("places") .. [[}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{place-1}]],
    [[\item{} \nameref{place-2} (Hometown, in \nameref{place-4})]],
    [[\end{itemize}]],
    [[\chapter{]] .. Tr("only-mentioned") .. [[}]],
    [[\subparagraph{Place 4}]],
    [[\label{place-4}]],
    [[\hspace{1cm}]]
}

Assert("entities-with-associations-and-locations", expected, out)
