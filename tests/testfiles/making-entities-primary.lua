local types = { "other", "places" }

local function entitySetup()
    for key1, typename1 in pairs(types) do
        local name1 = typename1
        TexApi.newEntity { type = typename1, label = name1, name = name1 }
        for key2, typename2 in pairs(types) do
            local name2 = typename1 .. "-" .. typename2
            TexApi.newEntity { type = typename2, label = name2, name = name2 }
            TexApi.addParent { parentLabel = name1 }
            for key3, typename3 in pairs(types) do
                local name3 = typename1 .. "-" .. typename2 .. "-" .. typename3
                TexApi.newEntity { type = typename3, label = name3, name = name3 }
                TexApi.addParent { parentLabel = name2 }
            end
        end
    end
end

local function generateLabels(typename, depth)
    local out = { typename }
    for i = 2, depth do
        local tmp = {}
        for key1, parentTypename in pairs(types) do
            for key2, name in pairs(out) do
                Append(tmp, parentTypename .. "-" .. name)
            end
        end
        out = tmp
    end
    return out
end

local function generateLabelChain(label)
    local labelChain = {}
    for elem in string.gmatch(label, "([^-]+)") do
        Append(labelChain, elem)
    end
    return labelChain
end

local function generateChildren(label)
    local labelChain = generateLabelChain(label)
    local hasChildren = #labelChain < 3
    local children = {}
    if hasChildren then
        for key, typename in pairs(types) do
            Append(children, label .. "-" .. typename)
        end
    end
    return children
end

local function generateParent(label)
    local labelChain = generateLabelChain(label)
    local parent = ""
    for i = 1, (#labelChain - 1) do
        if i == 1 then
            parent = labelChain[i]
        else
            parent = parent .. "-" .. labelChain[i]
        end
    end
    if parent == "" then
        return nil
    else
        return parent
    end
end

local function generateEntityFromLabel(label)
    local out = {}
    Append(out, [[\subsubsection{]] .. label .. [[}]])
    Append(out, [[\label{]] .. label .. [[}]])
    if #(generateChildren(label)) > 0 then
        for key, typename in pairs(types) do
            Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr(typename) .. [[}]])
            Append(out, [[\begin{itemize}]])
            Append(out, [[\item \nameref{]] .. label .. [[-]] .. typename .. [[}]])
            Append(out, [[\end{itemize}]])
        end
    end
    local parent = generateParent(label)
    if parent ~= nil then
        Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{]] .. parent .. [[}.]])
        Append(out, [[\end{itemize}]])
    end
    return out
end

local function generateMentioned(labels)
    local out = {}
    for key1, label in pairs(labels) do
        for key2, child in pairs(generateChildren(label)) do
            if not IsIn(child, labels) then
                UniqueAppend(out, child)
            end
        end
        local parent = generateParent(label)
        if parent ~= nil and not IsIn(parent, labels) then
            UniqueAppend(out, parent)
        end
    end
    return out
end

local function isType(label, typename)
    return label:sub(-string.len(typename)) == typename
end

local function generateChapter(typename, primaryLabels)
    local labelsOfType = {}
    for key, label in pairs(primaryLabels) do
        if isType(label, typename) then
            Append(labelsOfType, label)
        end
    end
    if #labelsOfType == 0 then
        return {}
    end
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr(typename)) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr(typename)) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr(typename)) .. [[}]])
    Append(out, [[\begin{itemize}]])
    for key, label in pairs(labelsOfType) do
        Append(out, [[\item \nameref{]] .. label .. [[}]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    for key, label in pairs(labelsOfType) do
        Append(out, generateEntityFromLabel(label))
    end
    return out
end

local function generateMentionedChapter(mentionedLabels)
    local out = {}
    if #mentionedLabels > 0 then
        Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
        for key, label in pairs(mentionedLabels) do
            Append(out, [[\subparagraph{]] .. label .. [[}]])
            Append(out, [[\label{]] .. label .. [[}]])
            Append(out, [[\hspace{1cm}]])
        end
    end
    return out
end

local function generatePrimareAndMentioned(arg)
    local primaryLabels = {}
    local mentionedLabels = {}
    if arg.primaryType ~= nil then
        for depth = 1, 3 do
            UniqueAppend(primaryLabels, generateLabels(arg.primaryType, depth))
        end
    end
    if arg.primaryParent ~= nil then
        UniqueAppend(primaryLabels, arg.primaryParent)
        UniqueAppend(primaryLabels, generateChildren(arg.primaryParent))
    end
    if arg.primaryTypeWhenMentioned ~= nil then
        local hasNotRun = true
        local somethingChanged = false
        while hasNotRun or somethingChanged do
            hasNotRun = false
            somethingChanged = false
            local currentlyMentioned = generateMentioned(primaryLabels)
            for key, label in pairs(currentlyMentioned) do
                if isType(label, arg.primaryTypeWhenMentioned) and not IsIn(label, primaryLabels) then
                    UniqueAppend(primaryLabels, label)
                    somethingChanged = true
                end
            end
        end
    end
    mentionedLabels = generateMentioned(primaryLabels)
    return primaryLabels, mentionedLabels
end

local function generateExpected(arg)
    local out = {}
    local primaryLabels, mentionedLabels = generatePrimareAndMentioned(arg)
    Sort(primaryLabels, "compareAlphanumerical")
    Sort(mentionedLabels, "compareAlphanumerical")

    for key, typename in pairs(types) do
        Append(out, generateChapter(typename, primaryLabels))
    end
    Append(out, generateMentionedChapter(mentionedLabels))
    return out
end

local expected = {}

local function typeSetup()
    TexApi.addType { metatype = "other", type = "other" }
    TexApi.addType { metatype = "places", type = "places" }
end

for key, typename in pairs(types) do
    entitySetup()
    local function refSetup()
        TexApi.makeAllEntitiesOfTypePrimary(typename)
        typeSetup()
    end

    expected = generateExpected { primaryType = typename }
    AssertAutomatedChapters("Type " .. typename .. " is primary", expected, refSetup)
end

for depth = 1, 3 do
    for key1, typename in pairs(types) do
        for key2, label in pairs(generateLabels(typename, depth)) do
            entitySetup()
            local function refSetupLabel()
                TexApi.makeEntityAndChildrenPrimary(label)
                typeSetup()
            end

            expected = generateExpected { primaryParent = label }
            local testname = "Entity '" .. label .. "' is primary"
            AssertAutomatedChapters(testname, expected, refSetupLabel)

            for key2, primaryTypename in pairs(types) do
                entitySetup()
                local function refSetupLabelAndType()
                    TexApi.makeEntityAndChildrenPrimary(label)
                    TexApi.makeTypePrimaryWhenMentioned(primaryTypename)
                    typeSetup()
                end

                expected = generateExpected { primaryParent = label, primaryTypeWhenMentioned = primaryTypename }
                local testname2 = testname .. ", type " .. primaryTypename .. " is primary when mentioned"
                AssertAutomatedChapters(testname2, expected, refSetupLabelAndType)
            end
        end
    end
end
