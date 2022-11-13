TexApi.newEntity { type = "places", label = "place-1", name = "Place 1" }
TexApi.newEntity { type = "places", label = "place-2", name = "Place 2" }
SetLocation(CurrentEntity(), "place-1")
TexApi.newEntity { type = "places", label = "place-3", name = "Place 3" }
SetLocation(CurrentEntity(), "place-2")
TexApi.newEntity { type = "classes", label = "class-1", name = "Class 1" }
TexApi.newEntity { type = "classes", label = "class-2", name = "Class 2" }
SetLocation(CurrentEntity(), "class-1")
TexApi.newEntity { type = "classes", label = "class-3", name = "Class 3" }
SetLocation(CurrentEntity(), "class-2")
AddAllEntitiesToPrimaryRefs()

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("classes")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("classes")) .. [[}]])

Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("classes")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{class-1}]])
Append(expected, [[\item{} \nameref{class-2}]])
Append(expected, [[\item{} \nameref{class-3}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection{Class 1}]])
Append(expected, [[\label{class-1}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("classes") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{class-2}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Class 1}]])
Append(expected, [[\subsubsection{Class 2}]])
Append(expected, [[\label{class-2}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("classes") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{class-3}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Class 1 - Class 2}]])
Append(expected, [[\subsubsection{Class 3}]])
Append(expected, [[\label{class-3}]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])

Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{place-1}]])
Append(expected, [[\item{} \nameref{place-2}]])
Append(expected, [[\item{} \nameref{place-3}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection{Place 1}]])
Append(expected, [[\label{place-1}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("places") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{place-2}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Place 1}]])
Append(expected, [[\subsubsection{Place 2}]])
Append(expected, [[\label{place-2}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("places") .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{place-3}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Place 1 - Place 2}]])
Append(expected, [[\subsubsection{Place 3}]])
Append(expected, [[\label{place-3}]])

local out = TexApi.automatedChapters()

Assert("nested-locations", expected, out)
