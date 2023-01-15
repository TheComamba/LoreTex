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
    local _, minusCount = string.gsub(label, "%-", "")
    local hasChildren = minusCount < 2
    local out = {}
    Append(out, [[subsubsection{]] .. label .. [[}]])
    Append(out, [[label{]] .. label .. [[}]])
    if hasChildren then
        for key, typename in pairs(types) do
            Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr(typename) .. [[}]])
            Append(out, [[\begin{itemize}]])
            Append(out, [[\item \nameref{]] .. label .. [[-]] .. typename .. [[}]])
            Append(out, [[\end{itemize}]])
        end
    end
    return out
end

local function generateExpected(arg)
    local out = {}
    if arg.primaryType ~= nil then
        local primaryLabels = {}
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
