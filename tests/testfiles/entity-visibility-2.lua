local function entitySetup()
    TexApi.newEntity { category = "stories", label = "teststory", name = "Teststory" }
    TexApi.addHistory { year = -10, content = [[Concerns \nameref{secret-item}.]] }

    TexApi.newEntity { category = "other", label = "secret-item", name = "Secret Item" }
    TexApi.setSecret()
end

local function generateHistoryParagraph()
    local out = {}
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out,
        [[\item -10 (]] ..
        Tr("x_years_ago", { 10 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{secret-item}.]])
    Append(out, [[\end{itemize}]])
    return out
end

local function generateExpected(isItemReferenced, isShowSecrets)
    local out = {}
    if isShowSecrets and isItemReferenced then
        Append(out, [[\chapter{Other}]])
        Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Other}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item \nameref{secret-item}]])
        Append(out, [[\end{itemize}]])
        Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
        Append(out, [[\subsection[Secret Item]{Secret Item (]] .. CapFirst(Tr("secret")) .. [[)}]])
        Append(out, [[\label{secret-item}]])
        Append(out, generateHistoryParagraph())
    end
    Append(out, [[\chapter{Stories}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Stories}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{teststory}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(out, [[\subsection{Teststory}]])
    Append(out, [[\label{teststory}]])
    if isShowSecrets then
        Append(out, generateHistoryParagraph())
    end

    if isShowSecrets and not isItemReferenced then
        Append(out, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])
        Append(out, [[\subparagraph{Secret Item}]])
        Append(out, [[\label{secret-item}]])
        Append(out, [[\hspace{1cm}]])
    end
    return out
end

local expected = {}

local function refSetup1()
    TexApi.makeEntityPrimary("teststory")
    TexApi.setCurrentYear(0)
end

local function refSetup2()
    refSetup1()
    TexApi.makeEntityPrimary("secret-item")
end

entitySetup()
local function setup1()
    refSetup1()
    TexApi.showSecrets(false)
end
expected = generateExpected(false, false)
AssertAutomatedChapters("entity-secrecy-two-do-not-show-secrets", expected, setup1)

entitySetup()
local function setup2()
    refSetup1()
    TexApi.showSecrets(true)
end
expected = generateExpected(false, true)
AssertAutomatedChapters("entity-secrecy-two-show-secrets", expected, setup2)

entitySetup()
local function setup3()
    refSetup2()
    TexApi.showSecrets(false)
end
expected = generateExpected(true, false)
AssertAutomatedChapters("entity-secrecy-two-do-not-show-secrets-but-item-referenced", expected, setup3)

entitySetup()
local function setup4()
    refSetup2()
    TexApi.showSecrets(true)
end
expected = generateExpected(true, true)
AssertAutomatedChapters("entity-secrecy-two-show-secrets, item referenced", expected, setup4)
