TexApi.setCurrentYear(0)

TexApi.newEntity { type = "NPCs", label = "flora", shortname = "", name = "Flora" }
TexApi.born { year = -10, event = [[\nameref{flora} is born.\birthof{flora}]] }
TexApi.died { year = -5, event = [[\nameref{flora} dies.\deathof{flora}]] }


TexApi.newEntity { type = "NPCs", label = "ramona", name = "Ramona" }
TexApi.setSecret()
TexApi.reveal("ramona")

local function refSetup()
    TexApi.makeEntityPrimary("flora")
    TexApi.makeEntityPrimary("ramona")
    TexApi.addType { metatype = "characters", type = "NPCs" }
end

local expected = {}
Append(expected, [[\chapter{NPCs}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{flora}]])
Append(expected, [[\item \nameref{ramona}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsection[Flora]{Flora \textdied{}}]])
Append(expected, [[\label{flora}]])
Append(expected, [[\subsubsection{]] .. CapFirst(Tr("appearance")) .. [[}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]])
Append(expected, Tr("aged") .. [[ 5 ]] .. Tr("years_old") .. [[.]])
Append(expected, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item -10 (]] .. Tr("x_years_ago", { 10 }) .. [[):\\\nameref{flora} is born.\birthof{flora}]])
Append(expected, [[\item -5 (]] .. Tr("x_years_ago", { 5 }) .. [[):\\\nameref{flora} dies.\deathof{flora}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection[Ramona]{Ramona (]] .. CapFirst(Tr("secret")) .. [[)}]])
Append(expected, [[\label{ramona}]])

AssertAutomatedChapters("Marked Entities", expected, refSetup)
