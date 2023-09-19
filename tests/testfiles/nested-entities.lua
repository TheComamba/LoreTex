local function setupTest(category, includesShortname, includesSubname)
    if includesShortname then
        TexApi.newEntity { category = category, label = category .. "-1", name = category .. " 1", shortname = "Shorty" }
    else
        TexApi.newEntity { category = category, label = category .. "-1", name = category .. " 1" }
    end

    TexApi.newEntity { category = category, label = category .. "-2", name = category .. " 2" }
    TexApi.setLocation(category .. "-1")
    if includesSubname then
        TexApi.setDescriptor { descriptor = "Subname", description = [[\label{sublabel}]] }
    end

    TexApi.newEntity { category = category, label = category .. "-3", name = category .. " 3" }
    if includesSubname then
        TexApi.setLocation("sublabel")
    else
        TexApi.setLocation(category .. "-2")
    end
end

local function generateExpected(category, includesShortname, includesSubname)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(category) .. [[}]])

    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(category) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. category .. [[-1}]])
    Append(out, [[\item \nameref{]] .. category .. [[-2}]])
    Append(out, [[\item \nameref{]] .. category .. [[-3}]])
    if includesSubname then
        Append(out, [[\item \nameref{sublabel}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    if includesShortname then
        Append(out, [[\subsection[Shorty]{]] .. CapFirst(category) .. [[ 1}]])
    else
        Append(out, [[\subsection{]] .. CapFirst(category) .. [[ 1}]])
    end
    Append(out, [[\label{]] .. category .. [[-1}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. CapFirst(category) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. category .. [[-2}]])
    Append(out, [[\end{itemize}]])

    if includesShortname then
        Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Shorty}]])
    else
        Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ ]] .. category .. [[ 1}]])
    end
    Append(out, [[\subsection{]] .. CapFirst(category) .. [[ 2}]])
    Append(out, [[\label{]] .. category .. [[-2}]])
    if includesSubname then
        Append(out, [[\subsubsection{Subname}]])
        Append(out, [[\label{sublabel}]])
        Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. CapFirst(category) .. [[}]])
    else
        Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. CapFirst(category) .. [[}]])
    end
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. category .. [[-3}]])
    Append(out, [[\end{itemize}]])

    if includesShortname then
        if includesSubname then
            Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Shorty - Subname}]])
        else
            Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Shorty - ]] .. category .. [[ 2}]])
        end
    else
        if includesSubname then
            Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ ]] .. category .. [[ 1 - Subname}]])
        else
            Append(out,
                [[\section{]] .. CapFirst(Tr("located_in")) .. [[ ]] .. category .. [[ 1 - ]] .. category .. [[ 2}]])
        end
    end
    Append(out, [[\subsection{]] .. CapFirst(category) .. [[ 3}]])
    Append(out, [[\label{]] .. category .. [[-3}]])
    return out
end

local function setup()
    TexApi.showSecrets()
    TexApi.makeAllEntitiesPrimary()
end

for key, category in pairs({ "places", "other" }) do
    for key, includesShortname in pairs({ false, true }) do
        for key, includesSubname in pairs({ false, true }) do
            setupTest(category, includesShortname, includesSubname)
            local expected = generateExpected(category, includesShortname, includesSubname)

            local testName = "Nested " .. category
            if includesShortname then
                testName = testName .. " with Shortname"
            end
            if includesSubname then
                testName = testName .. " with Subname"
            end
            AssertAutomatedChapters(testName, expected, setup)
        end
    end
end
