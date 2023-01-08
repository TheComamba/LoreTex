TexApi.setCurrentYear(0)

TexApi.newEntity { type = "stories", label = "teststory", name = "Teststory" }
TexApi.makeEntityPrimary("teststory")
TexApi.addHistory { year = -10, event = [[Concerns \nameref{secret-item}.]] }

TexApi.newEntity { type = "other", label = "secret-item", name = "Secret Item" }
TexApi.setSecret()

local function generateHistoryParagraph()
    local out = {}
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out,
        [[\item -10 (]] ..
        Tr("x-years-ago", { 10 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{secret-item}.]])
    Append(out, [[\end{itemize}]])
    return out
end

local function generateExpected(isItemReferenced, isShowSecrets)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("chronologies")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("stories")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("stories")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{teststory}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Teststory}]])
    Append(out, [[\label{teststory}]])
    if isShowSecrets then
        Append(out, generateHistoryParagraph())
        if isItemReferenced then
            Append(out, [[\chapter{]] .. CapFirst(Tr("other")) .. [[}]])
            Append(out, [[\section{]] .. CapFirst(Tr("other")) .. [[}]])
            Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("other")) .. [[}]])
            Append(out, [[\begin{itemize}]])
            Append(out, [[\item \nameref{secret-item}]])
            Append(out, [[\end{itemize}]])
            Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
            Append(out, [[\subsubsection[Secret Item]{Secret Item (]] .. CapFirst(Tr("secret")) .. [[)}]])
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

TexApi.showSecrets(false)
expected = generateExpected(false, false)
received = TexApi.automatedChapters()
Assert("entity-secrecey-two-do-not-show-secrets", expected, received)

TexApi.showSecrets(true)
expected = generateExpected(false, true)
received = TexApi.automatedChapters()
Assert("entity-secrecey-two-show-secrets", expected, received)

TexApi.makeEntityPrimary("secret-item")
TexApi.showSecrets(false)
expected = generateExpected(true, false)
received = TexApi.automatedChapters()
Assert("entity-secrecey-two-do-not-show-secrets", expected, received)

TexApi.showSecrets(true)
expected = generateExpected(true, true)
received = TexApi.automatedChapters()
Assert("entity-secrecey-two-show-secrets", expected, received)
