local function entitySetup()
    TexApi.newEntity { category = "places", label = "test-1", name = "Test 1" }
    TexApi.addHistoryOnlyHere { year = -10, content =
    [[Event that concerns \reference{test-1}, but not \reference{test-2}.]] }
    TexApi.addHistory { year = -20, content = [[Some event.]] }
    TexApi.addHistory { year = 5, content = [[Event in the future.]] }
    TexApi.addHistory { year = -987654321, content = [[Long time ago.]] }
    TexApi.addHistory { year = -2, day = 5, content = [[Event with day.]] }
    TexApi.addHistory { year = -2, day = 5, content = [[Event on same day.]] }
    TexApi.addHistory { year = -20, content = [[Event same year as another.]] }
    TexApi.addHistory { year = -1, content = [[Event last year.]] }
    TexApi.addHistory { year = -1, day = 1, content = [[Event last year, with day.]] }
    TexApi.addHistory { year = -1, day = 100, content = [[Event less than a year ago.]] }
    TexApi.addHistory { year = 0, content = [[Event this year.]] }
    TexApi.addHistory { year = 0, day = 5, content = [[Event this year, with day.]] }
    TexApi.addHistory { year = 0, day = 9, content = [[Event yesterday.]] }
    TexApi.addHistory { year = 0, day = 10, content = [[Event today.]] }
    TexApi.addHistory { year = 0, day = 11, content = [[Event tomorrow.]] }
    TexApi.addHistory { year = 0, day = 15, content = [[Event this year, with day in future.]] }
    TexApi.addHistory { year = 1, day = 5, content = [[Event in less than a year.]] }
    TexApi.addHistory { year = 1, content = [[Event next year.]] }
    TexApi.addHistory { year = 1, day = 15, content = [[Event next year, with day.]] }

    TexApi.newEntity { category = "places", label = "test-2", name = "Test 2" }
    TexApi.addHistory { year = -5,
        content = [[Event that concerns \reference{test-1}, but not \reference{test-2}.\notconcerns{test-2}]] }
end

local function setupBase()
    TexApi.makeEntityPrimary("test-1")
    TexApi.setCurrentYear(0)
    TexApi.setDaysPerYear(365)
end

local function generateExpected(isCurrentDaySet, isShowFuture)
    local out = {}
    Append(out, [[\chapter{Places}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Places}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{test-1}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(out, [[\subsection{Test 1}]])
    Append(out, [[\label{test-1}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])

    Append(out, [[\item -987654321 (]] .. Tr("x_years_ago", { 987654321 }) .. [[):\\Long time ago.]])
    Append(out, [[\item -20 (]] .. Tr("x_years_ago", { 20 }) .. [[):\\Some event.]])
    Append(out, [[\item Event same year as another.]])
    Append(out,
        [[\item -10 (]] ..
        Tr("x_years_ago", { 10 }) ..
        [[):\\Event that concerns \nameref{test-1}, but not \nameref{test-2}.]])
    Append(out,
        [[\item -5 (]] ..
        Tr("x_years_ago", { 5 }) ..
        [[):\\Event that concerns \nameref{test-1}, but not \nameref{test-2}.\notconcerns{test-2}]])


    Append(out, [[\item -2, ]] .. Tr("day") .. [[ 5 (]] .. Tr("x_years_ago", { 2 }) .. [[):\\Event with day.]])
    Append(out, [[\item Event on same day.]])

    Append(out, [[\item -1 (]] .. Tr("last_year") .. [[):\\ Event last year.]])
    Append(out, [[\item -1, ]] .. Tr("day") .. [[ 1 (]] .. Tr("last_year") .. [[):\\Event last year, with day.]])

    if isCurrentDaySet then
        Append(out,
            [[\item -1, ]] ..
            Tr("day") .. [[ 100 (]] .. Tr("x_days_ago", { 275 }) .. [[):\\Event less than a year ago.]])
        Append(out, [[\item 0 (]] .. Tr("this_year") .. [[):\\Event this year.]])
        Append(out,
            [[\item 0, ]] .. Tr("day") .. [[ 5 (]] .. Tr("x_days_ago", { 5 }) .. [[):\\Event this year, with day.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 9 (]] .. Tr("yesterday") .. [[):\\Event yesterday.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 10 (]] .. Tr("today") .. [[):\\Event today.]])

        if isShowFuture then
            Append(out, [[\item 0, ]] .. Tr("day") .. [[ 11 (]] .. Tr("tomorrow") .. [[):\\Event tomorrow.]])
            Append(out,
                [[\item 0, ]] ..
                Tr("day") .. [[ 15 (]] .. Tr("in_x_days", { 5 }) .. [[):\\Event this year, with day in future.]])
        end
    else
        Append(out,
            [[\item -1, ]] .. Tr("day") .. [[ 100 (]] .. Tr("last_year") .. [[):\\Event less than a year ago.]])
        Append(out, [[\item 0 (]] .. Tr("this_year") .. [[):\\Event this year.]])
        Append(out,
            [[\item 0, ]] .. Tr("day") .. [[ 5 (]] .. Tr("this_year") .. [[):\\Event this year, with day.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 9 (]] .. Tr("this_year") .. [[):\\Event yesterday.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 10 (]] .. Tr("this_year") .. [[):\\Event today.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 11 (]] .. Tr("this_year") .. [[):\\Event tomorrow.]])
        Append(out,
            [[\item 0, ]] ..
            Tr("day") .. [[ 15 (]] .. Tr("this_year") .. [[):\\Event this year, with day in future.]])
    end


    if isShowFuture then
        Append(out, [[\item 1 (]] .. Tr("next_year") .. [[):\\Event next year.]])
        if isCurrentDaySet then
            Append(out,
                [[\item 1, ]] ..
                Tr("day") .. [[ 5 (]] .. Tr("in_x_days", { 360 }) .. [[):\\Event in less than a year.]])
        else
            Append(out,
                [[\item 1, ]] ..
                Tr("day") .. [[ 5 (]] .. Tr("next_year") .. [[):\\Event in less than a year.]])
        end
        Append(out,
            [[\item 1, ]] ..
            Tr("day") .. [[ 15 (]] .. Tr("next_year") .. [[):\\Event next year, with day.]])
        Append(out, [[\item 5 (]] .. Tr("in_x_years", { 5 }) .. [[):\\Event in the future.]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])
    Append(out, [[\subparagraph{Test 2}]])
    Append(out, [[\label{test-2}]])
    Append(out, [[\hspace{1cm}]])
    return out
end

entitySetup()
local function setup1()
    setupBase()
    TexApi.showFuture(false)
end
local expected = generateExpected(false, false)
AssertAutomatedChapters("history-events-no-future-day-not-set", expected, setup1)

entitySetup()
local function setup2()
    setupBase()
    TexApi.showFuture(true)
end
expected = generateExpected(false, true)
AssertAutomatedChapters("history-events-with-future-day-not-set", expected, setup2)

entitySetup()
local function setup3()
    setupBase()
    TexApi.setCurrentDay(10)
    TexApi.showFuture(false)
end
local expected = generateExpected(true, false)
AssertAutomatedChapters("history-events-no-future-day-set", expected, setup3)

entitySetup()
local function setup4()
    setupBase()
    TexApi.setCurrentDay(10)
    TexApi.showFuture(true)
end
expected = generateExpected(true, true)
AssertAutomatedChapters("history-events-with-future-day-set", expected, setup4)
