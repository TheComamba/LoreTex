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
        return "subsubsection"
    elseif level == 2 then
        return "paragraph"
    elseif level == 3 then
        return "subparagraph"
    else
        return [[item \textbf]]
    end
end

local function addDescriptorsToExpected(expected, isSubdescription, level)
    if isSubdescription then
        if level > 3 then
            Append(expected, [[\begin{itemize}]])
        end

        Append(expected, [[\]] .. levelToCaptionstyle(level) .. [[{Test Descriptor}]])
        Append(expected, [[Test content]])

        if level > 2 then
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
        if level > 1 then
            Append(expected, [[\begin{itemize}]])
        end
        Append(expected, [[\]] .. levelToCaptionstyle(level + 2) .. [[{Alpha}]])
        Append(expected, [[$\alpha$]])
        Append(expected, [[\]] .. levelToCaptionstyle(level + 2) .. [[{Beta}]])
        Append(expected, [[$\beta$]])
        if level > 1 then
            Append(expected, [[\end{itemize}]])
        end

        if level > 2 then
            Append(expected, [[\end{itemize}]])
        end

        if level > 3 then
            Append(expected, [[\end{itemize}]])
        end
    else
        if level > 3 then
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
        if level > 2 then
            Append(expected, [[\begin{itemize}]])
        end
        Append(expected, [[\]] .. levelToCaptionstyle(level + 1) .. [[{Alpha}]])
        Append(expected, [[$\alpha$]])
        Append(expected, [[\]] .. levelToCaptionstyle(level + 1) .. [[{Beta}]])
        Append(expected, [[$\beta$]])
        if level > 2 then
            Append(expected, [[\end{itemize}]])
        end

        if level > 3 then
            Append(expected, [[\end{itemize}]])
        end
    end
end

local function setup()
    TexApi.makeAllEntitiesPrimary()
    TexApi.addType { metatype = "places", type = "places" }
end

for _, isSubdescription in pairs({ false, true }) do
    for i = 1, 4 do
        TexApi.newEntity { type = "places", label = "1", name = "Test" }
        TexApi.setDescriptor { descriptor = "ZZZSubentity",
            description = [[\label{2}
            \paragraph{ZZZSubsubentity} \label{3}
            \subparagraph{ZZZSubsubsubentity} \label{4}]] }
        setDescriptors(GetMutableEntityFromAll(tostring(i)), isSubdescription)

        local expected = {}
        Append(expected, [[\chapter{Places}]])
        Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Places}]])
        Append(expected, [[\begin{itemize}]])
        Append(expected, [[\item \nameref{1}]])
        Append(expected, [[\item \nameref{2}]])
        Append(expected, [[\item \nameref{3}]])
        Append(expected, [[\item \nameref{4}]])
        Append(expected, [[\end{itemize}]])
        Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])

        Append(expected, [[\subsection{Test}]])
        Append(expected, [[\label{1}]])
        if i == 1 then
            addDescriptorsToExpected(expected, isSubdescription, i)
        end
        Append(expected, [[\subsubsection{ZZZSubentity}]])
        Append(expected, [[\label{2}]])
        if i == 2 then
            addDescriptorsToExpected(expected, isSubdescription, i)
        end
        Append(expected, [[\paragraph{ZZZSubsubentity}]])
        Append(expected, [[\label{3}]])
        if i == 3 then
            addDescriptorsToExpected(expected, isSubdescription, i)
        end
        Append(expected, [[\subparagraph{ZZZSubsubsubentity}]])
        Append(expected, [[\label{4}]])
        if i == 4 then
            addDescriptorsToExpected(expected, isSubdescription, i)
        end

        local testname = "Descriptors with depth " .. i
        if isSubdescription then
            testname = "Sub-" .. testname
        end
        AssertAutomatedChapters(testname, expected, setup)
    end
end
