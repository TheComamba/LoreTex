size = 10

TexApi.newEntity { category = "places", label = "test-1", name = "Test 1" }
TexApi.newEntity { category = "places", label = "test-2", name = "Test 2" }
for i = 1, size do
    TexApi.addHistory { year = 0, content = [[Simple Event ]] .. (size - i) }
    TexApi.addHistory { year = 0, content = [[Concerns \ref{test-1} and \ref{test-2}\ref{test-2}\ref{test-2} ]] .. (size - i) }
    TexApi.addHistoryOnlyHere { year = 0, content = [[Only concerns \ref{test-2}, not \ref{test-1} ]] .. (size - i) }
    TexApi.addHistory { year = 0, day = 1, content = [[Has day ]] .. (size - i) }
end

local function setup()
    TexApi.makeAllEntitiesPrimary()
    TexApi.setCurrentYear(0)
    TexApi.setCurrentDay(0)
    TexApi.setDaysPerYear(365)
    TexApi.showFuture(true)
end

local function generateExpected()
    local out = {}
    Append(out, [[\chapter{Places}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Places}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{test-1}]])
    Append(out, [[\item \nameref{test-2}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(out, [[\subsection{Test 1}]])
    Append(out, [[\label{test-1}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    for i = 1, size do
        local pre = ""
        if i == 1 then
            pre = [[0 (]] .. Tr("this_year") .. [[):\\]]
        end
        Append(out,
            [[\item ]] .. pre .. [[Concerns \ref{test-1} and \ref{test-2}\ref{test-2}\ref{test-2} ]] .. (size - i))
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{Test 2}]])
    Append(out, [[\label{test-2}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    for i = 1, size do
        local pre = ""
        if i == 1 then
            pre = [[0 (]] .. Tr("this_year") .. [[):\\]]
        end
        Append(out, [[\item ]] .. pre .. [[Simple Event ]] .. (size - i))
        Append(out, [[\item Concerns \ref{test-1} and \ref{test-2}\ref{test-2}\ref{test-2} ]] .. (size - i))
        Append(out, [[\item Only concerns \ref{test-2}, not \ref{test-1} ]] .. (size - i))
    end
    for i = 1, size do
        local pre = ""
        if i == 1 then
            pre = [[0, ]] .. Tr("day") .. [[ 1 (]] .. Tr("tomorrow") .. [[):\\]]
        end
        Append(out, [[\item ]] .. pre .. [[Has day ]] .. (size - i))
    end
    Append(out, [[\end{itemize}]])
    return out
end

local expected = generateExpected()
AssertAutomatedChapters("history-many-items", expected, setup)
