local function entitySetup()
    TexApi.newEntity { type = "places", label = "test-1", name = "Test 1" }

    TexApi.newEntity { type = "places", label = "test-2", name = "Test 2" }
    TexApi.addHistory { year = -10, event = [[Event that concerns \reference{test-1} and \itref{test-2}.]] }
    TexApi.addHistory { year = 10, event = [[Event in the future.]] }
end

local function generateExpected(isSecondAdded)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{test-1}]])
    if isSecondAdded then
        Append(out, [[\item \nameref{test-2}]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Test 1}]])
    Append(out, [[\label{test-1}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out,
        [[\item -10 (]] ..
        Tr("x-years-ago", { 10 }) .. [[):\\ Event that concerns \nameref{test-1} and \itref{test-2}.]])
    Append(out, [[\end{itemize}]])
    if isSecondAdded then
        Append(out, [[\subsubsection{Test 2}]])
        Append(out, [[\label{test-2}]])
        Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out,
            [[\item -10 (]] ..
            Tr("x-years-ago", { 10 }) .. [[):\\ Event that concerns \nameref{test-1} and \itref{test-2}.]])
        Append(out, [[\end{itemize}]])
    else
        Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
        Append(out, [[\subparagraph{Test 2}]])
        Append(out, [[\label{test-2}]])
        Append(out, [[\hspace{1cm}]])
    end
    return out
end

local function refSetup1()
    TexApi.setCurrentYear(0)
    TexApi.makeEntityPrimary("test-1")
end

local function refSetup2()
    refSetup1()
    TexApi.makeEntityPrimary("test-2")
end

entitySetup()
local expected = generateExpected(false)
AssertAutomatedChapters("one-entity-with-history", expected, refSetup1)

entitySetup()
expected = generateExpected(true)
AssertAutomatedChapters("two-entities-with-history", expected, refSetup2)
