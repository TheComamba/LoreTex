NewEntity("places", "tattooine", nil, "Tattooine")

NewEntity("species", "tusken", nil, "Tusken")
SetLocation(CurrentEntity(), "tattooine")

NewEntity("species", "jawa", nil, "Jawa")
SetLocation(CurrentEntity(), "tattooine")

AddRef("tattooine", PrimaryRefs)

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{tattooine}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection{Tattooine}]])
Append(expected, [[\label{tattooine}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("species")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{jawa}]])
Append(expected, [[\item{} \nameref{tusken}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
Append(expected, [[\subparagraph{Jawa}]])
Append(expected, [[\label{jawa}]])
Append(expected, [[\hspace{1cm}]])
Append(expected, [[\subparagraph{Tusken}]])
Append(expected, [[\label{tusken}]])
Append(expected, [[\hspace{1cm}]])


local out = AutomatedChapters()
Assert("species-at-location", expected, out)
