local function setDescriptors(entity, isSubdescription)
    local someList = { "First", "Second" }
    local someMap = { Alpha = [[$\alpha$]], Beta = [[$\beta$]] }

    if isSubdescription then
        SetDescriptor { entity = entity,
            descriptor = "Test Descriptor",
            description = "Test content" }
        SetDescriptor { entity = entity,
            descriptor = "Test Descriptor",
            subdescriptor = "Some Subcontent",
            description = "Test subcontent" }
        SetDescriptor { entity = entity,
            descriptor = "Test Descriptor",
            subdescriptor = "Some Sublist",
            description = someList }
        SetDescriptor { entity = entity,
            descriptor = "Test Descriptor",
            subdescriptor = "Some Submap",
            description = someMap }
    else
        SetDescriptor { entity = entity, descriptor = "Some Content", description = "Test content" }
        SetDescriptor { entity = entity, descriptor = "Some List", description = someList }
        SetDescriptor { entity = entity, descriptor = "Some Map", description = someMap }
    end
end

local function levelToCaptionstyle(level)
    if level == 1 then
        return "paragraph"
    elseif level == 2 then
        return "subparagraph"
    else
        return [[item \textbf]]
    end
end

local function addDescriptorsToExpected(expected, isSubdescription, level)
    if isSubdescription then
        if level > 2 then
            Append(expected, [[\begin{itemize}]])
        end

        Append(expected, [[\]] .. levelToCaptionstyle(level) .. [[{Test Descriptor}]])
        Append(expected, [[Test content]])

        if level > 1 then
            Append(expected, [[\begin{itemize}]])
        end

        Append(expected, [[\]] .. levelToCaptionstyle(level + 1) .. [[{Some Subcontent}]])
        Append(expected, [[Test subcontent]])

        Append(expected, [[\]] .. levelToCaptionstyle(level + 1) .. [[{Some Sublist}]])
        Append(expected, [[\begin{itemize}]])
        Append(expected, [[\item First]])
        Append(expected, [[\item Second]])
        Append(expected, [[\end{itemize}]])

        Append(expected, [[\]] .. levelToCaptionstyle(level + 1) .. [[{Some Submap}]])
        Append(expected, [[\begin{itemize}]])
        Append(expected, [[\]] .. levelToCaptionstyle(level + 2) .. [[{Alpha}]])
        Append(expected, [[$\alpha$]])
        Append(expected, [[\]] .. levelToCaptionstyle(level + 2) .. [[{Beta}]])
        Append(expected, [[$\beta$]])
        Append(expected, [[\end{itemize}]])

        if level > 1 then
            Append(expected, [[\end{itemize}]])
        end

        if level > 2 then
            Append(expected, [[\end{itemize}]])
        end
    else
        if level > 2 then
            Append(expected, [[\begin{itemize}]])
        end
        Append(expected, [[\]] .. levelToCaptionstyle(level) .. [[{Some Content}]])
        Append(expected, [[Test content]])

        Append(expected, [[\]] .. levelToCaptionstyle(level) .. [[{Some List}]])
        Append(expected, [[\begin{itemize}]])
        Append(expected, [[\item First]])
        Append(expected, [[\item Second]])
        Append(expected, [[\end{itemize}]])

        Append(expected, [[\]] .. levelToCaptionstyle(level) .. [[{Some Map}]])
        if level > 1 then
            Append(expected, [[\begin{itemize}]])
        end
        Append(expected, [[\]] .. levelToCaptionstyle(level + 1) .. [[{Alpha}]])
        Append(expected, [[$\alpha$]])
        Append(expected, [[\]] .. levelToCaptionstyle(level + 1) .. [[{Beta}]])
        Append(expected, [[$\beta$]])
        if level > 1 then
            Append(expected, [[\end{itemize}]])
        end

        if level > 2 then
            Append(expected, [[\end{itemize}]])
        end
    end
end

for key, isSubdescription in pairs({ false, true }) do
    for i = 1, 3 do
        TexApi.newEntity { type = "places", label = "1", name = "Test" }
        TexApi.setDescriptor { descriptor = "ZZZSubentity",
            description = [[\label{2} \subparagraph{ZZZSubsubentity} \label{3}]] }
        setDescriptors(GetMutableEntityFromAll(tostring(i)), isSubdescription)

        local expected = {}
        Append(expected, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
        Append(expected, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
        Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
        Append(expected, [[\begin{itemize}]])
        Append(expected, [[\item \nameref{1}]])
        Append(expected, [[\item \nameref{2}]])
        Append(expected, [[\item \nameref{3}]])
        Append(expected, [[\end{itemize}]])
        Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])

        Append(expected, [[\subsubsection{Test}]])
        Append(expected, [[\label{1}]])
        if i == 1 then
            addDescriptorsToExpected(expected, isSubdescription, i)
        end
        Append(expected, [[\paragraph{ZZZSubentity}]])
        Append(expected, [[\label{2}]])
        if i == 2 then
            addDescriptorsToExpected(expected, isSubdescription, i)
        end
        Append(expected, [[\subparagraph{ZZZSubsubentity}]])
        Append(expected, [[\label{3}]])
        if i == 3 then
            addDescriptorsToExpected(expected, isSubdescription, i)
        end

        local testname = "Descriptors " .. i
        if isSubdescription then
            testname = "Sub-" .. testname
        end
        AssertAutomatedChapters(testname, expected, TexApi.makeAllEntitiesPrimary)
    end
end
