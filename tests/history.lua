TexApi.setCurrentYear(0)
TexApi.setDaysPerYear(365)

TexApi.newEntity { type = "places", label = "test-1", name = "Test 1" }
TexApi.addHistoryOnlyHere { year = -10, event = [[Event that concerns \reference{test-1}, but not \reference{test-2}.]] }
TexApi.addHistory { year = -20, event = [[Some event.]] }
TexApi.addHistory { year = 5, event = [[Event in the future.]] }
TexApi.addHistory { year = -987654321, event = [[Long time ago.]] }
TexApi.addHistory { year = -2, day = 5, event = [[Event with day.]] }
TexApi.addHistory { year = -2, day = 5, event = [[Event on same day.]] }
TexApi.addHistory { year = -20, event = [[Event same year as another.]] }
TexApi.addHistory { year = -1, event = [[Event last year.]] }
TexApi.addHistory { year = -1, day = 1, event = [[Event last year, with day.]] }
TexApi.addHistory { year = -1, day = 100, event = [[Event less than a year ago.]] }
TexApi.addHistory { year = 0, event = [[Event this year.]] }
TexApi.addHistory { year = 0, day = 5, event = [[Event this year, with day.]] }
TexApi.addHistory { year = 0, day = 9, event = [[Event yesterday.]] }
TexApi.addHistory { year = 0, day = 10, event = [[Event today.]] }
TexApi.addHistory { year = 0, day = 11, event = [[Event tomorrow.]] }
TexApi.addHistory { year = 0, day = 15, event = [[Event this year, with day in future.]] }
TexApi.addHistory { year = 1, day = 5, event = [[Event in less than a year.]] }
TexApi.addHistory { year = 1, event = [[Event next year.]] }
TexApi.addHistory { year = 1, day = 15, event = [[Event next year, with day.]] }

AddRef("test-1", PrimaryRefs)

TexApi.newEntity { type = "places", label = "test-2", name = "Test 2" }
TexApi.addHistory { year = -5,
    event = [[Event that concerns \reference{test-1}, but not \reference{test-2}.\notconcerns{test-2}]] }

local function generateExpected(isCurrentDaySet)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{test-1}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Test 1}]])
    Append(out, [[\label{test-1}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])

    Append(out, [[\item -987654321 (]] .. Tr("years-ago", { 987654321 }) .. [[):\\Long time ago.]])
    Append(out, [[\item -20 (]] .. Tr("years-ago", { 20 }) .. [[):\\Some event.]])
    Append(out, [[\item Event same year as another.]])
    Append(out,
        [[\item -10 (]] ..
        Tr("years-ago", { 10 }) ..
        [[):\\Event that concerns \nameref{test-1}, but not \nameref{test-2}.]])
    Append(out,
        [[\item -5 (]] ..
        Tr("years-ago", { 5 }) ..
        [[):\\Event that concerns \nameref{test-1}, but not \nameref{test-2}.\notconcerns{test-2}]])


    Append(out, [[\item -2, ]] .. Tr("day") .. [[ 5 (]] .. Tr("years-ago", { 2 }) .. [[):\\Event with day.]])
    Append(out, [[\item Event on same day.]])

    Append(out, [[\item -1 (]] .. Tr("last-year") .. [[):\\ Event last year.]])
    Append(out, [[\item -1, ]] .. Tr("day") .. [[ 1 (]] .. Tr("last-year") .. [[):\\Event last year, with day.]])

    if isCurrentDaySet then
        Append(out,
            [[\item -1, ]] ..
            Tr("day") .. [[ 100 (]] .. Tr("days-ago", { 275 }) .. [[):\\Event less than a year ago.]])
        Append(out, [[\item 0 (]] .. Tr("this-year") .. [[):\\Event this year.]])
        Append(out,
            [[\item 0, ]] .. Tr("day") .. [[ 5 (]] .. Tr("days-ago", { 5 }) .. [[):\\Event this year, with day.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 9 (]] .. Tr("yesterday") .. [[):\\Event yesterday.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 10 (]] .. Tr("today") .. [[):\\Event today.]])

        if IsShowFuture then
            Append(out, [[\item 0, ]] .. Tr("day") .. [[ 11 (]] .. Tr("tomorrow") .. [[):\\Event tomorrow.]])
            Append(out,
                [[\item 0, ]] ..
                Tr("day") .. [[ 15 (]] .. Tr("in-days", { 5 }) .. [[):\\Event this year, with day in future.]])
        end
    else
        Append(out,
            [[\item -1, ]] .. Tr("day") .. [[ 100 (]] .. Tr("last-year") .. [[):\\Event less than a year ago.]])
        Append(out, [[\item 0 (]] .. Tr("this-year") .. [[):\\Event this year.]])
        Append(out,
            [[\item 0, ]] .. Tr("day") .. [[ 5 (]] .. Tr("this-year") .. [[):\\Event this year, with day.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 9 (]] .. Tr("this-year") .. [[):\\Event yesterday.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 10 (]] .. Tr("this-year") .. [[):\\Event today.]])
        Append(out, [[\item 0, ]] .. Tr("day") .. [[ 11 (]] .. Tr("this-year") .. [[):\\Event tomorrow.]])
        Append(out,
            [[\item 0, ]] ..
            Tr("day") .. [[ 15 (]] .. Tr("this-year") .. [[):\\Event this year, with day in future.]])
    end


    if IsShowFuture then
        Append(out, [[\item 1 (]] .. Tr("next-year") .. [[):\\Event next year.]])
        if isCurrentDaySet then
            Append(out,
                [[\item 1, ]] ..
                Tr("day") .. [[ 5 (]] .. Tr("in-days", { 360 }) .. [[):\\Event in less than a year.]])
        else
            Append(out,
                [[\item 1, ]] ..
                Tr("day") .. [[ 5 (]] .. Tr("next-year") .. [[):\\Event in less than a year.]])
        end
        Append(out,
            [[\item 1, ]] ..
            Tr("day") .. [[ 15 (]] .. Tr("next-year") .. [[):\\Event next year, with day.]])
        Append(out, [[\item 5 (]] .. Tr("in-years", { 5 }) .. [[):\\Event in the future.]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
    Append(out, [[\subparagraph{Test 2}]])
    Append(out, [[\label{test-2}]])
    Append(out, [[\hspace{1cm}]])
    return out
end

IsShowFuture = false
local out = TexApi.automatedChapters()
local expected = generateExpected(false)
Assert("history-events-no-future-day-not-set", expected, out)

IsShowFuture = true
out = TexApi.automatedChapters()
expected = generateExpected(false)
Assert("history-events-with-future-day-not-set", expected, out)


TexApi.setCurrentDay(10)

IsShowFuture = false
local out = TexApi.automatedChapters()
local expected = generateExpected(true)
Assert("history-events-no-future-day-set", expected, out)

IsShowFuture = true
out = TexApi.automatedChapters()
expected = generateExpected(true)
Assert("history-events-with-future-day-set", expected, out)
