NewEntity("test-1", "places", nil, "Test 1")
AddEvent(CurrentEntity(), -20, [[Some event.]])
AddEvent(CurrentEntity(), 5, [[Event in the future.]])
NewEntity("test-2", "places", nil, "Test 2")

AddEvent(nil, -10, [[Event that concerns \reference{test-1}, but not \reference{test-2}.\notconcerns{test-2}]])

AddRef("test-1", PrimaryRefs)

local function generateExpected()
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{test-1}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Test 1}]])
    Append(out, [[\label{test-1}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} -20 Vin (]] .. Tr("years-ago", { 20 }) .. [[): Some event.]])
    Append(out,
        [[\item{} -10 Vin (]] ..
        Tr("years-ago", { 10 }) ..
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
