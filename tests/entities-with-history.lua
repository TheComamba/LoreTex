NewEntity("places", "test-1", nil, "Test 1")

NewEntity("places", "test-2", nil, "Test 2")
ProcessEvent(CurrentEntity(), -10, [[Event that concerns \reference{test-1} and \itref{test-2}.]])
ProcessEvent(CurrentEntity(), 10, [[Event in the future.]])

AddRef("test-1", PrimaryRefs)

local function generateExpected(isSecondAdded)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{test-1}]])
    if isSecondAdded then
        Append(out, [[\item{} \nameref{test-2}]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Test 1}]])
    Append(out, [[\label{test-1}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out,
        [[\item{} -10 Vin (]] .. Tr("years-ago", { 10 }) ..
        [[): Event that concerns \nameref{test-1} and \itref{test-2}.]])
    Append(out, [[\end{itemize}]])
    if isSecondAdded then
        Append(out, [[\subsubsection{Test 2}]])
        Append(out, [[\label{test-2}]])
        Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out,
            [[\item{} -10 Vin (]] ..
            Tr("years-ago", { 10 }) .. [[): Event that concerns \nameref{test-1} and \itref{test-2}.]])
        Append(out, [[\end{itemize}]])
    else
        Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
        Append(out, [[\subparagraph{Test 2}]])
        Append(out, [[\label{test-2}]])
        Append(out, [[\hspace{1cm}]])
    end
    return out
end

IsShowFuture = false

local out = AutomatedChapters()

local expected = generateExpected(false)

Assert("one-entity-with-history", expected, out)

AddRef("test-2", PrimaryRefs)

out = AutomatedChapters()

expected = generateExpected(true)

Assert("two-entities-with-history", expected, out)
