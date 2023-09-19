local categories = { "other", "places" }

local function entitySetup()
    for _, category1 in pairs(categories) do
        local name1 = category1
        TexApi.newEntity { category = category1, label = name1, name = name1 }
        for _, category2 in pairs(categories) do
            local name2 = category1 .. "-" .. category2
            TexApi.newEntity { category = category2, label = name2, name = name2 }
            TexApi.addParent { parentLabel = name1 }
            for _, category3 in pairs(categories) do
                local name3 = category1 .. "-" .. category2 .. "-" .. category3
                TexApi.newEntity { category = category3, label = name3, name = name3 }
                TexApi.addParent { parentLabel = name2 }
            end
        end
    end
end

local function generateLabels(category, depth)
    local out = { category }
    for i = 2, depth do
        local tmp = {}
        for _, parentCategory in pairs(categories) do
            for _, name in pairs(out) do
                Append(tmp, parentCategory .. "-" .. name)
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
        for _, category in pairs(categories) do
            Append(children, label .. "-" .. category)
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
    Append(out, [[\subsection{]] .. CapFirst(label) .. [[}]])
    Append(out, [[\label{]] .. label .. [[}]])
    if #(generateChildren(label)) > 0 then
        for _, category in pairs(categories) do
            Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. CapFirst(category) .. [[}]])
            Append(out, [[\begin{itemize}]])
            Append(out, [[\item \nameref{]] .. label .. [[-]] .. category .. [[}]])
            Append(out, [[\end{itemize}]])
        end
    end
    local parent = generateParent(label)
    if parent ~= nil then
        Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliations")) .. [[}]])
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

local function isCategory(label, category)
    return label:sub(-string.len(category)) == category
end

local function generateChapter(category, primaryLabels)
    local labelsOfCategory = {}
    for key, label in pairs(primaryLabels) do
        if isCategory(label, category) then
            Append(labelsOfCategory, label)
        end
    end
    if #labelsOfCategory == 0 then
        return {}
    end
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(category) .. [[}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(category) .. [[}]])
    Append(out, [[\begin{itemize}]])
    for key, label in pairs(labelsOfCategory) do
        Append(out, [[\item \nameref{]] .. label .. [[}]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    for key, label in pairs(labelsOfCategory) do
        Append(out, generateEntityFromLabel(label))
    end
    return out
end

local function generateMentionedChapter(mentionedLabels)
    local out = {}
    if #mentionedLabels > 0 then
        Append(out, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])
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
    if arg.primaryCategory ~= nil then
        for depth = 1, 3 do
            UniqueAppend(primaryLabels, generateLabels(arg.primaryCategory, depth))
        end
    end
    if arg.primaryParent ~= nil then
        UniqueAppend(primaryLabels, arg.primaryParent)
        UniqueAppend(primaryLabels, generateChildren(arg.primaryParent))
    end
    if arg.primaryCategoryWhenMentioned ~= nil then
        local hasNotRun = true
        local somethingChanged = false
        while hasNotRun or somethingChanged do
            hasNotRun = false
            somethingChanged = false
            local currentlyMentioned = generateMentioned(primaryLabels)
            for key, label in pairs(currentlyMentioned) do
                if isCategory(label, arg.primaryCategoryWhenMentioned) and not IsIn(label, primaryLabels) then
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

    for _, category in pairs(categories) do
        Append(out, generateChapter(category, primaryLabels))
    end
    Append(out, generateMentionedChapter(mentionedLabels))
    return out
end

local expected = {}

for _, category in pairs(categories) do
    entitySetup()
    local function setup()
        TexApi.showSecrets()
        TexApi.makeAllEntitiesOfCategoryPrimary(category)
    end

    expected = generateExpected { primaryCategory = category }
    AssertAutomatedChapters("Category " .. category .. " is primary", expected, setup)
end

for depth = 1, 3 do
    for _, category in pairs(categories) do
        for _, label in pairs(generateLabels(category, depth)) do
            entitySetup()
            local function setup1()
                TexApi.showSecrets()
                TexApi.makeEntityAndChildrenPrimary(label)
            end

            expected = generateExpected { primaryParent = label }
            local testname = "Entity '" .. label .. "' is primary"
            AssertAutomatedChapters(testname, expected, setup1)

            for _, primaryCategory in pairs(categories) do
                entitySetup()
                local function setup2()
                    TexApi.showSecrets()
                    TexApi.makeEntityAndChildrenPrimary(label)
                    TexApi.makeCategoryPrimaryWhenMentioned(primaryCategory)
                end

                expected = generateExpected { primaryParent = label, primaryCategoryWhenMentioned = primaryCategory }
                local testname2 = testname .. ", category " .. primaryCategory .. " is primary when mentioned"
                AssertAutomatedChapters(testname2, expected, setup2)
            end
        end
    end
end
