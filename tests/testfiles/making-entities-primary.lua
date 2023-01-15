local types = { "other", "places" }

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

local function generateEntityFromLabel(label)
    local labelChain = {}
    for elem in string.gmatch(label, "([^-]+)") do
        Append(labelChain, elem)
    end
    local hasChildren = #labelChain < 3
    local parent = ""
    for i = 1, (#labelChain - 1) do
        if i == 1 then
            parent = labelChain[i]
        else
            parent = parent .. "-" .. labelChain[i]
        end
    end
    local out = {}
    Append(out, [[\subsubsection{]] .. label .. [[}]])
    Append(out, [[\label{]] .. label .. [[}]])
    if hasChildren then
        for key, typename in pairs(types) do
            Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr(typename) .. [[}]])
            Append(out, [[\begin{itemize}]])
            Append(out, [[\item \nameref{]] .. label .. [[-]] .. typename .. [[}]])
            Append(out, [[\end{itemize}]])
        end
    end
    if parent ~= "" then
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
        local labelChain = {}
        for elem in string.gmatch(label, "([^-]+)") do
            Append(labelChain, elem)
        end
        local hasChildren = #labelChain < 3
        if hasChildren then
            for key2, typename in pairs(types) do
                local child = label .. "-" .. typename
                if not IsIn(child, labels) then
                    UniqueAppend(out, child)
                end
            end
        end
        local parent = ""
        for i = 1, (#labelChain - 1) do
            if i == 1 then
                parent = labelChain[i]
            else
                parent = parent .. "-" .. labelChain[i]
            end
        end
        if parent ~= "" and not IsIn(parent, labels) then
            UniqueAppend(out, parent)
        end
    end
    return out
end

local function generateExpected(arg)
    local out = {}
    local primaryLabels = {}
    local mentionedLabels = {}
    if arg.primaryType ~= nil then
        for depth = 1, 3 do
            Append(primaryLabels, generateLabels(arg.primaryType, depth))
        end
        Sort(primaryLabels, "compareAlphanumerical")

        Append(out, [[\chapter{]] .. CapFirst(Tr(arg.primaryType)) .. [[}]])
        Append(out, [[\section{]] .. CapFirst(Tr(arg.primaryType)) .. [[}]])
        Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr(arg.primaryType)) .. [[}]])
        Append(out, [[\begin{itemize}]])
        for key, label in pairs(primaryLabels) do
            Append(out, [[\item \nameref{]] .. label .. [[}]])
        end
        Append(out, [[\end{itemize}]])
        Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
        for key, label in pairs(primaryLabels) do
            Append(out, generateEntityFromLabel(label))
        end
    end
    mentionedLabels = generateMentioned(primaryLabels)
    Sort(mentionedLabels, "compareAlphanumerical")
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

local expected = {}
local out = {}

for key, typename in pairs(types) do
    ResetRefs()

    TexApi.makeAllEntitiesOfTypePrimary(typename)

    expected = generateExpected { primaryType = typename }
    out = TexApi.automatedChapters()

    Assert("Type " .. typename .. " is primary", expected, out)
end

for key, typename in pairs(types) do
    for depth = 1, 3 do
        ResetRefs()
        local label = ""
        for i = 1, depth do
            label = label .. typename
        end
        TexApi.makeEntityAndChildrenPrimary(label)
        expected = generateExpected {}
        out = TexApi.automatedChapters()
        local testname = "Entity " .. label .. " is primary"
        Assert(testname, expected, out)

        for key2, primaryTypename in pairs(types) do
            TexApi.makeTypePrimaryWhenMentioned(primaryTypename)
            expected = generateExpected {}
            out = TexApi.automatedChapters()
            testname = testname .. ", type " .. primaryTypename .. " is primary when mentioned"
            Assert(testname, expected, out)
        end
    end
end
