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
end

local function generateExpected(typename, includesShortname, includesSubname)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(typename) .. [[}]])

    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(typename) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-1}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-2}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-3}]])
    if includesSubname then
        Append(out, [[\item \nameref{sublabel}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    if includesShortname then
        Append(out, [[\subsection[Shorty]{]] .. typename .. [[ 1}]])
    else
        Append(out, [[\subsection{]] .. CapFirst(typename) .. [[ 1}]])
    end
    Append(out, [[\label{]] .. typename .. [[-1}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. CapFirst(typename) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-2}]])
    Append(out, [[\end{itemize}]])

    if includesShortname then
        Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Shorty}]])
    else
        Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ ]] .. typename .. [[ 1}]])
    end
    Append(out, [[\subsection{]] .. CapFirst(typename) .. [[ 2}]])
    Append(out, [[\label{]] .. typename .. [[-2}]])
    if includesSubname then
        Append(out, [[\subsubsection{Subname}]])
        Append(out, [[\label{sublabel}]])
        Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. CapFirst(typename) .. [[}]])
    else
        Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. CapFirst(typename) .. [[}]])
    end
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{]] .. typename .. [[-3}]])
    Append(out, [[\end{itemize}]])

    if includesShortname then
        if includesSubname then
            Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Shorty - Subname}]])
        else
            Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Shorty - ]] .. typename .. [[ 2}]])
        end
    else
        if includesSubname then
            Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ ]] .. typename .. [[ 1 - Subname}]])
        else
            Append(out,
                [[\section{]] .. CapFirst(Tr("located_in")) .. [[ ]] .. typename .. [[ 1 - ]] .. typename .. [[ 2}]])
        end
    end
    Append(out, [[\subsection{]] .. CapFirst(typename) .. [[ 3}]])
    Append(out, [[\label{]] .. typename .. [[-3}]])
    return out
end

local function setup()
    TexApi.makeAllEntitiesPrimary()
    TexApi.addType { metatype = "places", type = "places" }
    TexApi.addType { metatype = "other", type = "other" }
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
            AssertAutomatedChapters(testName, expected, setup)
        end
    end
end
