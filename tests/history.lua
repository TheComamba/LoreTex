NewEntity("places", "test-1", nil, "Test 1")
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    hist["year"] = -20
    hist["event"] = [[Some event.]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    hist["year"] = -10
    hist["event"] = [[Event that concerns \reference{test-1}, but not \reference{test-2}.]]
    hist["isConcernsOthers"] = false
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "test-1"
    hist["year"] = 5
    hist["event"] = [[Event in the future.]]
    ProcessEvent(hist)
end
NewEntity("places", "test-2", nil, "Test 2")
if true then
    local hist = EmptyHistoryItem()
    hist["year"] = -5
    hist["event"] = [[Event that concerns \reference{test-1}, but not \reference{test-2}.\notconcerns{test-2}]]
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

IsShowFuture = false
local out = AutomatedChapters()
local expected = generateExpected()
Assert("history-events-no-future", expected, out)

IsShowFuture = true
out = AutomatedChapters()
expected = generateExpected()
Assert("history-events-with-future", expected, out)
