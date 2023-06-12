local function setupTest(typename, includesShortname, includesSubname)
    if includesShortname then
        TexApi.newEntity { type = typename, label = typename .. "-1", name = typename .. " 1", shortname = "Shorty" }
    else
        TexApi.newEntity { type = typename, label = typename .. "-1", name = typename .. " 1" }
    end

    TexApi.newEntity { type = typename, label = typename .. "-2", name = typename .. " 2" }
    TexApi.setLocation(typename .. "-1")
    if includesSubname then
        TexApi.setDescriptor { descriptor = "Subname", description = [[\label{sublabel}]] }
    end

    TexApi.newEntity { type = typename, label = typename .. "-3", name = typename .. " 3" }
    if includesSubname then
        TexApi.setLocation("sublabel")
    else
        TexApi.setLocation(typename .. "-2")
    end

    TexApi.makeAllEntitiesPrimary()
end

local function generateExpected(typename, includesShortname, includesSubname)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr(typename)) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr(typename)) .. [[}]])

    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr(typename)) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-1}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-2}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-3}]])
    if includesSubname then
        Append(out, [[\item \nameref{sublabel}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    if includesShortname then
        Append(out, [[\subsubsection[Shorty]{]] .. typename .. [[ 1}]])
    else
        Append(out, [[\subsubsection{]] .. typename .. [[ 1}]])
    end
    Append(out, [[\label{]] .. typename .. [[-1}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr(typename) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-2}]])
    Append(out, [[\end{itemize}]])

    if includesShortname then
        Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Shorty}]])
    else
        Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ ]] .. typename .. [[ 1}]])
    end
    Append(out, [[\subsubsection{]] .. typename .. [[ 2}]])
    Append(out, [[\label{]] .. typename .. [[-2}]])
    if includesSubname then
        Append(out, [[\paragraph{Subname}]])
        Append(out, [[\label{sublabel}]])
        Append(out, [[\subparagraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr(typename) .. [[}]])
    else
        Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr(typename) .. [[}]])
    end
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-3}]])
    Append(out, [[\end{itemize}]])

    if includesShortname then
        if includesSubname then
            Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Shorty - Subname}]])
        else
            Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Shorty - ]] .. typename .. [[ 2}]])
        end
    else
        if includesSubname then
            Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ ]] .. typename .. [[ 1 - Subname}]])
        else
            Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ ]] .. typename .. [[ 1 - ]] .. typename .. [[ 2}]])
        end
    end
    Append(out, [[\subsubsection{]] .. typename .. [[ 3}]])
    Append(out, [[\label{]] .. typename .. [[-3}]])
    return out
end

for key, typename in pairs({ "places", "other" }) do
    for key, includesShortname in pairs({ false, true }) do
        for key, includesSubname in pairs({ false, true }) do
            setupTest(typename, includesShortname, includesSubname)
            local expected = generateExpected(typename, includesShortname, includesSubname)

            local testName = "Nested " .. typename
            if includesShortname then
                testName = testName .. " with Shortname"
            end
            if includesSubname then
                testName = testName .. " with Subname"
            end
            AssertAutomatedChapters(testName, expected)
        end
    end
end
