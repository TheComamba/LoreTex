NewEntity("stories", "teststory", nil, "Teststory")
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "teststory"
    SetYear(hist, -10)
    hist["event"] = [[Concerns \nameref{secret-item}.]]
    ProcessEvent(hist)
end
AddRef("teststory", PrimaryRefs)
NewEntity("items", "secret-item", "", "Secret Item")
SetSecret(CurrentEntity())

local function generateHistoryParagraph()
    local out = {}
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out,
        [[\item{} -10 Vin (]] ..
        Tr("years-ago", { 10 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{secret-item}.]])
    Append(out, [[\end{itemize}]])
    return out
end

local function generateExpected(isItemReferenced)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("chronologies")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("stories")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("stories")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{teststory}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Teststory}]])
    Append(out, [[\label{teststory}]])
    if IsShowSecrets then
        Append(out, generateHistoryParagraph())
        if isItemReferenced then
            Append(out, [[\chapter{]] .. CapFirst(Tr("items")) .. [[}]])
            Append(out, [[\section{]] .. CapFirst(Tr("items")) .. [[}]])
            Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("items")) .. [[}]])
            Append(out, [[\begin{itemize}]])
            Append(out, [[\item{} \nameref{secret-item}]])
            Append(out, [[\end{itemize}]])
            Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
            Append(out, [[\subsubsection[Secret Item]{(]] .. CapFirst(Tr("secret")) .. [[)Secret Item}]])
            Append(out, [[\label{secret-item}]])
            Append(out, generateHistoryParagraph())
        else
            Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
            Append(out, [[\subparagraph{Secret Item}]])
            Append(out, [[\label{secret-item}]])
            Append(out, [[\hspace{1cm}]])
        end
    end
    return out
end

local expected = {}
local received = {}

IsShowSecrets = false
expected = generateExpected(false)
received = AutomatedChapters()
Assert("entity-secrecey-two-do-not-show-secrets", expected, received)

IsShowSecrets = true
expected = generateExpected(false)
received = AutomatedChapters()
Assert("entity-secrecey-two-show-secrets", expected, received)

AddRef("secret-item", PrimaryRefs)
IsShowSecrets = false
expected = generateExpected(true)
received = AutomatedChapters()
Assert("entity-secrecey-two-do-not-show-secrets", expected, received)

IsShowSecrets = true
expected = generateExpected(true)
received = AutomatedChapters()
Assert("entity-secrecey-two-show-secrets", expected, received)
