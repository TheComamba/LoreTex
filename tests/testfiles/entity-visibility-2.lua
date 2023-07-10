local function entitySetup()
    TexApi.newEntity { type = "stories", label = "teststory", name = "Teststory" }
    TexApi.addHistory { year = -10, event = [[Concerns \nameref{secret-item}.]] }

    TexApi.newEntity { type = "other", label = "secret-item", name = "Secret Item" }
    TexApi.setSecret()
end

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

local function refSetup1()
    TexApi.makeEntityPrimary("teststory")
    TexApi.addType { metatype = "chronologies", type = "stories" }
    TexApi.addType { metatype = "other", type = "other" }
    TexApi.setCurrentYear(0)
end

local function refSetup2()
    refSetup1()
    TexApi.makeEntityPrimary("secret-item")
end

entitySetup()
TexApi.showSecrets(false)
expected = generateExpected(false, false)
AssertAutomatedChapters("entity-secrecy-two-do-not-show-secrets", expected, refSetup1)

entitySetup()
TexApi.showSecrets(true)
expected = generateExpected(false, true)
AssertAutomatedChapters("entity-secrecy-two-show-secrets", expected, refSetup1)

entitySetup()
TexApi.showSecrets(false)
expected = generateExpected(true, false)
AssertAutomatedChapters("entity-secrecy-two-do-not-show-secrets-but-item-referenced", expected, refSetup2)

entitySetup()
TexApi.showSecrets(true)
expected = generateExpected(true, true)
AssertAutomatedChapters("entity-secrecy-two-show-secrets, item referenced", expected, refSetup2)
