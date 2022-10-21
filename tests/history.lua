NewEntity("test-1", "places", nil, "Test 1")
AddEvent(CurrentEntity(), -20, [[Some event.]])
AddEvent(nil, -10, [[Event that concerns \reference{test-1}.]])
AddEvent(CurrentEntity(), 5, [[Event in the future.]])

AddAllEntitiesToPrimaryRefs()

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
    Append(out, [[\item{} -10 Vin (]] .. Tr("years-ago", { 10 }) .. [[): Event that concerns \nameref{test-1}.]])
    if IsShowFuture then
        Append(out, [[\item{} 5 Vin (]] .. Tr("in-years", { 5 }) .. [[): Event in the future.]])
    end
    Append(out, [[\end{itemize}]])
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
