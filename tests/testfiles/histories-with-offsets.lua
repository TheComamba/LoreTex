local function entitySetup()
    TexApi.newEntity { type = "calendars", label = "test-calendar-with-offset", name = "Test Calendar with Offset" }
    TexApi.setYearOffset(10)

    TexApi.newEntity { type = "other", label = "test", name = "Test Entity" }
    TexApi.addHistory { yearFmt = "test-calendar-with-offset", year = 11, event = "Event with offset." }
    local itemEnteredInFormat = AllHistoryItems[#AllHistoryItems]
    TexApi.addHistory { year = 0, event = "Event without offset." }

    Assert("Year of item entered in offsetted format", 1, GetProtectedNullableField(itemEnteredInFormat, "year"))
end

local function setupBase()
    TexApi.setCurrentDay(1)
    TexApi.setDaysPerYear(200)
    TexApi.setCurrentYear(100)
    TexApi.makeEntityPrimary("test")
    TexApi.addType { metatype = "other", type = "other" }
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
    Append(out, [[\chapter{]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{test}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Test Entity}]])
    Append(out, [[\label{test}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    local year = 0
    if hasOffset then
        year = 10
    end
    Append(out, [[\item ]] .. year .. [[ (]] .. Tr("x-years-ago", { 100 }) .. [[):\\Event without offset.]])
    Append(out, [[\item ]] .. (year + 1) .. [[ (]] .. Tr("x-years-ago", { 99 }) .. [[):\\Event with offset.]])
    Append(out, [[\end{itemize}]])
    return out
end

entitySetup()
local expected = generateExpected(false)
AssertAutomatedChapters("history with offset, standard output", expected, setupNoOffset)

entitySetup()
local expected = generateExpected(true)
AssertAutomatedChapters("history with offset, offseted output", expected, setupWithOffset)
