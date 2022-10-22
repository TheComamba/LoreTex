NewEntity("primary-item", "items", nil, "Primary Item")
AddRef("primary-item", PrimaryRefs)
SetDescriptor(CurrentEntity(), "Description", [[Different than \nameref{other-item}.]])
SetDescriptor(CurrentEntity(), "associations", "some-association")

NewEntity("mentioned-item", "items", nil, "Mentioned Item")
AddRef("mentioned-item", MentionedRefs)

NewEntity("other-item", "items", nil, "Other Item")

NewEntity("not-mentioned-item", "items", nil, "Not mentioned Item")

NewEntity("some-association", "associations", nil, "Some Association")

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("items")) .. [[}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("items")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{primary-item}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("items")) .. [[}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection{Primary Item}]])
Append(expected, [[\label{primary-item}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("associations")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{some-association}.]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\paragraph{Description}]])
Append(expected, [[Different than \nameref{other-item}.]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
Append(expected, [[\subparagraph{Mentioned Item}]])
Append(expected, [[\label{mentioned-item}]])
Append(expected, [[\hspace{1cm}]])
Append(expected, [[\subparagraph{Other Item}]])
Append(expected, [[\label{other-item}]])
Append(expected, [[\hspace{1cm}]])
Append(expected, [[\subparagraph{Some Association}]])
Append(expected, [[\label{some-association}]])
Append(expected, [[\hspace{1cm}]])

local out = AutomatedChapters()

Assert("mentioned-refs", expected, out)