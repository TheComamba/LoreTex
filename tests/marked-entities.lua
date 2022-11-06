NewEntity("npcs", "flora", "", "Flora")
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "flora"
    SetYear(hist, -10)
    hist["event"] = [[\nameref{flora} is born.\birthof{flora}]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "flora"
    SetYear(hist, -5)
    hist["event"] = [[\nameref{flora} dies.\deathof{flora}]]
    ProcessEvent(hist)
end
AddRef("flora", PrimaryRefs)

NewEntity("npcs", "ramona", "", "Ramona")
SetSecret(CurrentEntity())
Reveal("ramona")
AddRef("ramona", PrimaryRefs)

local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} \nameref{flora}]])
Append(expected, [[\item{} \nameref{ramona}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
Append(expected, [[\subsubsection[Flora]{Flora \textdied{}}]])
Append(expected, [[\label{flora}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
Append(expected, [[\subparagraph{]] .. CapFirst(Tr("species-and-age")) .. [[:} ]] .. Tr("aged") .. [[ 5 ]] .. Tr("years-old") .. [[.]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item{} -10 Vin (]] .. Tr("years-ago", {10}) .. [[):\\\nameref{flora} is born.\birthof{flora}]])
Append(expected, [[\item{} -5 Vin (]] .. Tr("years-ago", {5}) .. [[):\\\nameref{flora} dies.\deathof{flora}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsubsection[Ramona]{(]] .. CapFirst(Tr("secret")) .. [[) Ramona}]])
Append(expected, [[\label{ramona}]])


local out = AutomatedChapters()
Assert("Dead entity", expected, out)
