TexApi.setCurrentYear(0)

TexApi.newEntity { type = "npcs", label = "flora", shortname = "", name = "Flora" }
TexApi.born { year = -10, event = [[\nameref{flora} is born.\birthof{flora}]] }
TexApi.died { year = -5, event = [[\nameref{flora} dies.\deathof{flora}]] }

TexApi.makeEntityPrimary("flora")

TexApi.newEntity { type = "npcs", label = "ramona", name = "Ramona" }
TexApi.setSecret()
TexApi.reveal("ramona")
TexApi.makeEntityPrimary("ramona")

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{flora}]])
Append(expected, [[\item \nameref{ramona}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection[Flora]{Flora \textdied{}}]])
Append(expected, [[\label{flora}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
Append(expected, [[\subparagraph{]] .. CapFirst(Tr("species-and-age")) .. [[:}]])
Append(expected, Tr("aged") .. [[ 5 ]] .. Tr("years-old") .. [[.]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item -10 (]] .. Tr("x-years-ago", { 10 }) .. [[):\\\nameref{flora} is born.\birthof{flora}]])
Append(expected, [[\item -5 (]] .. Tr("x-years-ago", { 5 }) .. [[):\\\nameref{flora} dies.\deathof{flora}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsubsection[Ramona]{Ramona (]] .. CapFirst(Tr("secret")) .. [[)}]])
Append(expected, [[\label{ramona}]])


local out = TexApi.automatedChapters()
Assert("Marked Entities", expected, out)
