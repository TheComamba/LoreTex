NewEntity("items", "primary-item", nil, "Primary Item")
AddRef("primary-item", PrimaryRefs)
SetDescriptor(CurrentEntity(), "Description", [[Different than \nameref{other-item}.]])
AddParent(CurrentEntity(), "some-organisation")

NewEntity("items", "mentioned-item", nil, "Mentioned Item")
AddRef("mentioned-item", MentionedRefs)

NewEntity("items", "other-item", nil, "Other Item")

NewEntity("items", "not-mentioned-item", nil, "Not mentioned Item")

NewEntity("organisations", "some-organisation", nil, "Some Organisation")

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("items")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("items")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("items")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{primary-item}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection{Primary Item}]])
Append(expected, [[\label{primary-item}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{some-organisation}.]])
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
Append(expected, [[\subparagraph{Some Organisation}]])
Append(expected, [[\label{some-organisation}]])
Append(expected, [[\hspace{1cm}]])

local out = AutomatedChapters()

Assert("mentioned-refs", expected, out)