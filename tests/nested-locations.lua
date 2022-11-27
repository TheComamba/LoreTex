local function setupTest(typename)
    ResetState()
    TexApi.newEntity { type = typename, label = typename .. "-1", name = typename .. " 1" }
    TexApi.newEntity { type = typename, label = typename .. "-2", name = typename .. " 2" }
    TexApi.setLocation(typename .. "-1")
    TexApi.newEntity { type = typename, label = typename .. "-3", name = typename .. " 3" }
    TexApi.setLocation(typename .. "-2")
    AddAllEntitiesToPrimaryRefs()
end

local function generateExpected(typename)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr(typename)) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr(typename)) .. [[}]])

    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr(typename)) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-1}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-2}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-3}]])
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{]] .. typename .. [[ 1}]])
    Append(out, [[\label{]] .. typename .. [[-1}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr(typename) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-2}]])
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ ]] .. typename .. [[ 1}]])
    Append(out, [[\subsubsection{]] .. typename .. [[ 2}]])
    Append(out, [[\label{]] .. typename .. [[-2}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr(typename) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-3}]])
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ ]] .. typename .. [[ 1 - ]] .. typename .. [[ 2}]])
    Append(out, [[\subsubsection{]] .. typename .. [[ 3}]])
    Append(out, [[\label{]] .. typename .. [[-3}]])
    return out
end

for key, typename in pairs({ "places", "classes" }) do
    setupTest(typename)
    local expected = generateExpected(typename)
    local out = TexApi.automatedChapters()
    Assert("nested-" .. typename, expected, out)
end
