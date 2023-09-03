local function entitySetup()
    TexApi.newEntity { category = "calendars", label = "test-calendar-with-offset", name = "Test Calendar with Offset" }
    TexApi.setYearOffset(10)

    TexApi.newEntity { category = "other", label = "test", name = "Test Entity" }
    TexApi.addHistory { yearFmt = "test-calendar-with-offset", year = 11, content = "Event with offset." }
    local itemEnteredInFormat = AllHistoryItems[#AllHistoryItems]
    TexApi.addHistory { year = 0, content = "Event without offset." }

    Assert("Year of item entered in offsetted format", 1, GetProtectedNullableField(itemEnteredInFormat, "year"))
end

local function setupBase()
    TexApi.setCurrentDay(1)
    TexApi.setDaysPerYear(200)
    TexApi.setCurrentYear(100)
    TexApi.makeEntityPrimary("test")
end

local function setupNoOffset()
    setupBase()
end

local function setupWithOffset()
    setupBase()
    TexApi.addYearFmt("test-calendar-with-offset")
end

local function generateExpected(hasOffset)
    local out = {}
    Append(out, [[\chapter{Other}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Other}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{test}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(out, [[\subsection{Test Entity}]])
    Append(out, [[\label{test}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    local year = 0
    if hasOffset then
        year = 10
    end
    Append(out, [[\item ]] .. year .. [[ (]] .. Tr("x_years_ago", { 100 }) .. [[):\\Event without offset.]])
    Append(out, [[\item ]] .. (year + 1) .. [[ (]] .. Tr("x_years_ago", { 99 }) .. [[):\\Event with offset.]])
    Append(out, [[\end{itemize}]])
    return out
end

entitySetup()
local expected = generateExpected(false)
AssertAutomatedChapters("history with offset, standard output", expected, setupNoOffset)

entitySetup()
local expected = generateExpected(true)
AssertAutomatedChapters("history with offset, offseted output", expected, setupWithOffset)
