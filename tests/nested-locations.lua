NewEntity("places", "place-1", nil, "Place 1")
NewEntity("places", "place-2", nil, "Place 2")
SetLocation(CurrentEntity(), "place-1")
NewEntity("places", "place-3", nil, "Place 3")
SetLocation(CurrentEntity(), "place-2")
NewEntity("classes", "class-1", nil, "Class 1")
NewEntity("classes", "class-2", nil, "Class 2")
SetLocation(CurrentEntity(), "class-1")
NewEntity("classes", "class-3", nil, "Class 3")
SetLocation(CurrentEntity(), "class-2")
AddAllEntitiesToPrimaryRefs()

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("classes")).. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("classes")).. [[}]])

Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")).. [[ ]] .. CapFirst(Tr("classes")).. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{class-1}]])
Append(expected, [[\item{} \nameref{class-2}]])
Append(expected, [[\item{} \nameref{class-3}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")).. [[}]])
Append(expected, [[\subsubsection{Class 1}]])
Append(expected, [[\label{class-1}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("classes") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{class-2}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in")).. [[ Class 1}]])
Append(expected, [[\subsubsection{Class 2}]])
Append(expected, [[\label{class-2}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("classes") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{class-3}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in")).. [[ Class 1 - Class 2}]])
Append(expected, [[\subsubsection{Class 3}]])
Append(expected, [[\label{class-3}]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("places")).. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("places")).. [[}]])

Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")).. [[ ]] .. CapFirst(Tr("places")).. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{place-1}]])
Append(expected, [[\item{} \nameref{place-2}]])
Append(expected, [[\item{} \nameref{place-3}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")).. [[}]])
Append(expected, [[\subsubsection{Place 1}]])
Append(expected, [[\label{place-1}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("places") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{place-2}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in")).. [[ Place 1}]])
Append(expected, [[\subsubsection{Place 2}]])
Append(expected, [[\label{place-2}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("places") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{place-3}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in")).. [[ Place 1 - Place 2}]])
Append(expected, [[\subsubsection{Place 3}]])
Append(expected, [[\label{place-3}]])

local out = AutomatedChapters()

Assert("nested-locations", expected, out)