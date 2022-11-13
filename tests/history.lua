TexApi.newEntity { type = "places", label = "test-1", name = "Test 1" }
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, -10)
    SetProtectedField(hist, "event", [[Event that concerns \reference{test-1}, but not \reference{test-2}.]])
    SetProtectedField(hist, "isConcernsOthers", false)
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, -20)
    SetProtectedField(hist, "event", [[Some event.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 5)
    SetProtectedField(hist, "event", [[Event in the future.]])
    ProcessEvent(hist)
end

TexApi.newEntity { type = "places", label = "test-2", name = "Test 2" }
if true then
    local hist = EmptyHistoryItem()
    SetYear(hist, -5)
    SetProtectedField(hist, "event",
        [[Event that concerns \reference{test-1}, but not \reference{test-2}.\notconcerns{test-2}]])
    ProcessEvent(hist)
end

if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, -987654321)
    SetProtectedField(hist, "event", [[Long time ago.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, -2)
    SetDay(hist, 5)
    SetProtectedField(hist, "event", [[Event with day.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, -2)
    SetDay(hist, 5)
    SetProtectedField(hist, "event", [[Event on same day.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, -20)
    SetProtectedField(hist, "event", [[Event same year as another.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, -1)
    SetProtectedField(hist, "event", [[Event last year.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, -1)
    SetDay(hist, 1)
    SetProtectedField(hist, "event", [[Event last year, with day.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, -1)
    SetDay(hist, 100)
    SetProtectedField(hist, "event", [[Event less than a year ago.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 0)
    SetProtectedField(hist, "event", [[Event this year.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 0)
    SetDay(hist, 5)
    SetProtectedField(hist, "event", [[Event this year, with day.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 0)
    SetDay(hist, 9)
    SetProtectedField(hist, "event", [[Event yesterday.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 0)
    SetDay(hist, 10)
    SetProtectedField(hist, "event", [[Event today.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 0)
    SetDay(hist, 11)
    SetProtectedField(hist, "event", [[Event tomorrow.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 0)
    SetDay(hist, 15)
    SetProtectedField(hist, "event", [[Event this year, with day in future.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 1)
    SetDay(hist, 5)
    SetProtectedField(hist, "event", [[Event in less than a year.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 1)
    SetProtectedField(hist, "event", [[Event next year.]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "test-1")
    SetYear(hist, 1)
    SetDay(hist, 15)
    SetProtectedField(hist, "event", [[Event next year, with day.]])
    ProcessEvent(hist)
end


AddRef("test-1", PrimaryRefs)

local function generateExpected()
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{test-1}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Test 1}]])
    Append(out, [[\label{test-1}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])

    Append(out, [[\item{} -987654321 (]] .. Tr("years-ago", { 987654321 }) .. [[):\\Long time ago.]])
    Append(out, [[\item{} -20 (]] .. Tr("years-ago", { 20 }) .. [[):\\Some event.]])
    Append(out, [[\item{} Event same year as another.]])
    Append(out,
        [[\item{} -10 (]] ..
        Tr("years-ago", { 10 }) ..
        [[):\\Event that concerns \nameref{test-1}, but not \nameref{test-2}.]])
    Append(out,
        [[\item{} -5 (]] ..
        Tr("years-ago", { 5 }) ..
        [[):\\Event that concerns \nameref{test-1}, but not \nameref{test-2}.\notconcerns{test-2}]])


    Append(out, [[\item{} -2, ]] .. Tr("day") .. [[ 5 (]] .. Tr("years-ago", { 2 }) .. [[):\\Event with day.]])
    Append(out, [[\item{} Event on same day.]])

    Append(out, [[\item{} -1 (]] .. Tr("last-year") .. [[):\\ Event last year.]])
    Append(out, [[\item{} -1, ]] .. Tr("day") .. [[ 1 (]] .. Tr("last-year") .. [[):\\Event last year, with day.]])

    if CurrentDay == 0 then
        Append(out,
            [[\item{} -1, ]] .. Tr("day") .. [[ 100 (]] .. Tr("last-year") .. [[):\\Event less than a year ago.]])
        Append(out, [[\item{} 0 (]] .. Tr("this-year") .. [[):\\Event this year.]])
        Append(out,
            [[\item{} 0, ]] .. Tr("day") .. [[ 5 (]] .. Tr("this-year") .. [[):\\Event this year, with day.]])
        Append(out, [[\item{} 0, ]] .. Tr("day") .. [[ 9 (]] .. Tr("this-year") .. [[):\\Event yesterday.]])
        Append(out, [[\item{} 0, ]] .. Tr("day") .. [[ 10 (]] .. Tr("this-year") .. [[):\\Event today.]])
        Append(out, [[\item{} 0, ]] .. Tr("day") .. [[ 11 (]] .. Tr("this-year") .. [[):\\Event tomorrow.]])
        Append(out,
            [[\item{} 0, ]] ..
            Tr("day") .. [[ 15 (]] .. Tr("this-year") .. [[):\\Event this year, with day in future.]])
    else
        Append(out,
            [[\item{} -1, ]] ..
            Tr("day") .. [[ 100 (]] .. Tr("days-ago", { 274 }) .. [[):\\Event less than a year ago.]])
        Append(out, [[\item{} 0 (]] .. Tr("this-year") .. [[):\\Event this year.]])
        Append(out,
            [[\item{} 0, ]] .. Tr("day") .. [[ 5 (]] .. Tr("days-ago", { 5 }) .. [[):\\Event this year, with day.]])
        Append(out, [[\item{} 0, ]] .. Tr("day") .. [[ 9 (]] .. Tr("yesterday") .. [[):\\Event yesterday.]])
        Append(out, [[\item{} 0, ]] .. Tr("day") .. [[ 10 (]] .. Tr("today") .. [[):\\Event today.]])

        if IsShowFuture then
            Append(out, [[\item{} 0, ]] .. Tr("day") .. [[ 11 (]] .. Tr("tomorrow") .. [[):\\Event tomorrow.]])
            Append(out,
                [[\item{} 0, ]] ..
                Tr("day") .. [[ 15 (]] .. Tr("in-days", { 5 }) .. [[):\\Event this year, with day in future.]])
        end
    end


    if IsShowFuture then
        Append(out, [[\item{} 1 (]] .. Tr("next-year") .. [[):\\Event next year.]])
        if CurrentDay == 0 then
            Append(out,
                [[\item{} 1, ]] ..
                Tr("day") .. [[ 5 (]] .. Tr("next-year") .. [[):\\Event in less than a year.]])
        else
            Append(out,
                [[\item{} 1, ]] ..
                Tr("day") .. [[ 5 (]] .. Tr("in-days", { 359 }) .. [[):\\Event in less than a year.]])
        end
        Append(out,
            [[\item{} 1, ]] ..
            Tr("day") .. [[ 15 (]] .. Tr("next-year") .. [[):\\Event next year, with day.]])
        Append(out, [[\item{} 5 (]] .. Tr("in-years", { 5 }) .. [[):\\Event in the future.]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
    Append(out, [[\subparagraph{Test 2}]])
    Append(out, [[\label{test-2}]])
    Append(out, [[\hspace{1cm}]])
    return out
end

CurrentYear = 0
CurrentDay = 0

IsShowFuture = false
local out = TexApi.automatedChapters()
local expected = generateExpected()
Assert("history-events-no-future-day-not-set", expected, out)

IsShowFuture = true
out = TexApi.automatedChapters()
expected = generateExpected()
Assert("history-events-with-future-day-not-set", expected, out)


CurrentDay = 10

IsShowFuture = false
local out = TexApi.automatedChapters()
local expected = generateExpected()
Assert("history-events-no-future-day-set", expected, out)

IsShowFuture = true
out = TexApi.automatedChapters()
expected = generateExpected()
Assert("history-events-with-future-day-set", expected, out)
