TexApi.newEntity { category = "NPCs", label = "flora", shortname = "", name = "Flora" }
TexApi.born { year = -10, content = [[\nameref{flora} is born.\birthof{flora}]] }
TexApi.died { year = -5, content = [[\nameref{flora} dies.\deathof{flora}]] }

TexApi.newEntity { category = "NPCs", label = "ramona", name = "Ramona" }
TexApi.setSecret()

local function setup()
    TexApi.showSecrets()
    TexApi.setCurrentYear(0)
    TexApi.makeEntityPrimary("flora")
    TexApi.makeEntityPrimary("ramona")
    TexApi.reveal("ramona")
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

AssertAutomatedChapters("Marked Entities", expected, setup)
