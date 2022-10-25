NewEntity("organisations", "test", nil, "Test")

MakePrimaryIf(Bind(IsType, "associations"))

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("associations")).. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("organisations")).. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")).. [[ ]] .. CapFirst(Tr("organisations")).. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{test}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")).. [[}]])
Append(expected, [[\subsubsection{Test}]])
Append(expected, [[\label{test}]])

local out = AutomatedChapters()

Assert("make-primary-if", expected, out)