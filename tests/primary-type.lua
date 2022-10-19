NewEntity("karl", "npcs", nil, "Karl")
SetDescriptor(CurrentEntity(), "species", "human")
SetDescriptor(CurrentEntity(), "Friend", [[\nameref{peter}]])
NewEntity("peter", "npcs", nil, "Peter")
SetDescriptor(CurrentEntity(), "species", "human")
NewEntity("human", "species", nil, "Human")
AddRef("karl", PrimaryRefs)

local out = AutomatedChapters()

local expected = {
    [[\chapter{Characters}]],
    [[\section*{All Characters}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{karl}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In the whole World}]],
    [[\subsubsection{Karl}]],
    [[\label{karl}]],
    [[\paragraph{Appearance}]],
    [[\subparagraph{Species and Age:}\nameref {human}.]],
    [[\paragraph{Friend}]],
    [[\nameref{peter}]],
    [[\chapter{Only mentioned}]],
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
    [[\chapter{Characters}]],
    [[\section*{All Characters}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{karl}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In the whole World}]],
    [[\subsubsection{Karl}]],
    [[\label{karl}]],
    [[\paragraph{Appearance}]],
    [[\subparagraph{Species and Age:}\nameref {human}.]],
    [[\paragraph{Friend}]],
    [[\nameref{peter}]],
    [[\chapter{Species}]],
    [[\section*{All Species}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{human}]],
    [[\end{itemize}]],
    [[\section{Species}]],
    [[\subsection{In the whole World}]],
    [[\subsubsection{Human}]],
    [[\label{human}]],
    [[\chapter{Only mentioned}]],
    [[\subparagraph{Peter}]],
    [[\label{peter}]],
    [[\hspace{1cm}]]
}

Assert("species-are-primary-types", expected, out)

local out = AutomatedChapters()

local expected = {
    [[\chapter{Characters}]],
    [[\section*{All Characters}]],
    [[\begin{itemize}]],
    [[\item{} \nameref{karl}]],
    [[\item{} \nameref{peter}]],
    [[\end{itemize}]],
    [[\section{NPCs}]],
    [[\subsection{In the whole World}]],
    [[\subsubsection{Karl}]],
    [[\label{karl}]],
    [[\paragraph{Appearance}]],
    [[\subparagraph{Species and Age:}\nameref {human}.]],
    [[\paragraph{Friend}]],
    [[\nameref{peter}]],
    [[\subsubsection{Peter}]],
    [[\label{peter}]],
    [[\chapter{Only mentioned}]],
    [[\subparagraph{Human}]],
    [[\label{human}]],
    [[\hspace{1cm}]]
}

Assert("npcs-are-primary-types", expected, out)

