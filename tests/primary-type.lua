NewEntity("karl", "npc", nil, "Karl")
SetDescriptor(CurrentEntity(), "species", "human")
SetDescriptor(CurrentEntity(), "Friend", [[\nameref{peter}]])
NewEntity("peter", "npc", nil, "Peter")
SetDescriptor(CurrentEntity(), "species", "human")
NewEntity("human", "species", nil, "Human")
AddRef("karl", PrimaryRefs)

local out = AutomatedChapters()

local expected = {
    [[\chapter{Charaktere}]],
    [[\section*{Alle Charaktere}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{karl}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Karl}]],
    [[\label{karl}]],
    [[\paragraph{Erscheinung}]],
    [[\subparagraph{Spezies und Alter:}\nameref {human}.]],
    [[\paragraph{Friend}]],
    [[\nameref{peter}]],
    [[\chapter{Nur erwähnt}]],
    [[\subparagraph{Human}]],
    [[\label{human}]],
    [[\hspace{1cm}]],
    [[\subparagraph{Peter}]],
    [[\label{peter}]],
    [[\hspace{1cm}]]
}

Assert("two-npcs-one-mentioned", expected, out)

local out = AutomatedChapters()

local expected = {
    [[\chapter{Charaktere}]],
    [[\section*{Alle Charaktere}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{karl}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Karl}]],
    [[\label{karl}]],
    [[\paragraph{Erscheinung}]],
    [[\subparagraph{Spezies und Alter:}\nameref {human}.]],
    [[\paragraph{Friend}]],
    [[\nameref{peter}]],
    [[\chapter{Spezies}]],
    [[\section*{Alle Spezies}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{human}]],
    [[\end{itemize}]],
    [[\section{Spezies}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Human}]],
    [[\label{human}]],
    [[\chapter{Nur erwähnt}]],
    [[\subparagraph{Peter}]],
    [[\label{peter}]],
    [[\hspace{1cm}]]
}

Assert("species-are-primary-types", expected, out)

local out = AutomatedChapters()

local expected = {
    [[\chapter{Charaktere}]],
    [[\section*{Alle Charaktere}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{karl}]],
    [[\item{} \nameref{peter}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In der ganzen Welt}]],
    [[\subsubsection{Karl}]],
    [[\label{karl}]],
    [[\paragraph{Erscheinung}]],
    [[\subparagraph{Spezies und Alter:}\nameref {human}.]],
    [[\paragraph{Friend}]],
    [[\nameref{peter}]],
    [[\subsubsection{Peter}]],
    [[\label{peter}]],
    [[\chapter{Nur erwähnt}]],
    [[\subparagraph{Human}]],
    [[\label{human}]],
    [[\hspace{1cm}]]
}

Assert("npcs-are-primary-types", expected, out)

