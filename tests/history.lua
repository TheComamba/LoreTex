NewEntity("places", "test-1", nil, "Test 1")
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, -10)
    hist["event"] = [[Event that concerns \reference{test-1}, but not \reference{test-2}.]]
    hist["isConcernsOthers"] = false
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, -20)
    hist["event"] = [[Some event.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 5)
    hist["event"] = [[Event in the future.]]
    ProcessEvent(hist)
end

NewEntity("places", "test-2", nil, "Test 2")
if true then
    local hist = EmptyHistoryItem()
    SetYear(hist, -5)
    hist["event"] = [[Event that concerns \reference{test-1}, but not \reference{test-2}.\notconcerns{test-2}]]
    ProcessEvent(hist)
end

if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, -987654321)
    hist["event"] = [[Long time ago.]]
    ProcessEvent(hist)
end

if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, -2)
    SetDay(hist, 5)
    hist["event"] = [[Event with day.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, -2)
    SetDay(hist, 5)
    hist["event"] = [[Event on same day.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, -1)
    hist["event"] = [[Event last year.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, -1)
    SetDay(hist, 1)
    hist["event"] = [[Event last year, with day.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, -1)
    SetDay(hist, 100)
    hist["event"] = [[Event less than a year ago.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 0)
    hist["event"] = [[Event this year.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 0)
    SetDay(hist, 5)
    hist["event"] = [[Event this year, with day.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 0)
    SetDay(hist, 9)
    hist["event"] = [[Event yesterday.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 0)
    SetDay(hist, 10)
    hist["event"] = [[Event today.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 0)
    SetDay(hist, 11)
    hist["event"] = [[Event tomorrow.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 0)
    SetDay(hist, 15)
    hist["event"] = [[Event this year, with day in future.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 1)
    SetDay(hist, 5)
    hist["event"] = [[Event in less than a year.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 1)
    hist["event"] = [[Event next year.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    SetYear(hist, 1)
    SetDay(hist, 15)
    hist["event"] = [[Event next year, with day.]]
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
    Append(out, [[\item{} -20 Vin (]] .. Tr("years-ago", { 20 }) .. [[): Some event.]])
    Append(out,
        [[\item{} -10 Vin (]] ..
        Tr("years-ago", { 10 }) ..
        [[): Event that concerns \nameref{test-1}, but not \nameref{test-2}.]])
    Append(out,
        [[\item{} -5 Vin (]] ..
        Tr("years-ago", { 5 }) ..
        [[): Event that concerns \nameref{test-1}, but not \nameref{test-2}.\notconcerns{test-2}]])
    if IsShowFuture then
        Append(out, [[\item{} 5 Vin (]] .. Tr("in-years", { 5 }) .. [[): Event in the future.]])
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
local out = AutomatedChapters()
local expected = generateExpected()
Assert("history-events-no-future", expected, out)

IsShowFuture = true
out = AutomatedChapters()
expected = generateExpected()
Assert("history-events-with-future", expected, out)


CurrentDay = 10

IsShowFuture = false
local out = AutomatedChapters()
local expected = generateExpected()
Assert("history-events-no-future", expected, out)

IsShowFuture = true
out = AutomatedChapters()
expected = generateExpected()
Assert("history-events-with-future", expected, out)
