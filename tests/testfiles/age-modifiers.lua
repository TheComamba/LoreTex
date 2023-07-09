local function newEntity(name, depth)
    TexApi.newEntity { label = name .. 1, name = name .. 1, type = "other" }
    if depth == 2 then
        TexApi.setDescriptor { descriptor = name .. 2, description = [[\label{]] .. name .. 2 .. [[}]] }
    elseif depth == 3 then
        TexApi.setDescriptor { descriptor = name .. 2,
            description = [[\subparagraph{]] .. name .. 3 .. [[}\label{]] .. name .. 3 .. [[}]] }
    end
end

local function generateHumanAgeCentury(modification)
    if modification == "normal" then
        return 100
    elseif modification == "factor" then
        return 125
    elseif modification == "exponent" then
        return 46
    elseif modification == "both" then
        return 56
    elseif modification == "mixing" then
        return 74
    end
end

local function generateAppearance(depth, modification)
    local out = {}
    Append(out, [[\nameref {]])
    if modification == "mixing" then
        Append(out, "species-3-" .. depth)
    else
        Append(out, "species-1-" .. depth)
    end
    Append(out, [[}, 100 ]])
    Append(out, Tr("years-old"))
    if modification == "not-aging" then
        Append(out, " (" .. Tr("does-not-age") .. ")")
    elseif modification == "factor" or modification == "exponent" or modification == "both" or modification == "mixing" then
        Append(out, " (" .. Tr("corresponding-human-age") .. " ")
        Append(out, generateHumanAgeCentury(modification))
        Append(out, " " .. Tr("years") .. ")")
    end
    Append(out, ".")
    return table.concat(out)
end

local lifeStages = { "juvenile", "young", "adult", "old", "ancient" }

local function generateAgeAtLifestages(modification)
    if modification == "normal" then
        return { 12, 20, 30, 60, 90 }
    elseif modification == "factor" then
        return { 10, 16, 24, 48, 72 }
    elseif modification == "exponent" then
        return { 20, 36, 59 }
    elseif modification == "both" then
        return { 16, 29, 47 }
    elseif modification == "mixing" then
        return { 14, 24, 37, 79 }
    else
        return {}
    end
end

local function generateLifestageString(key, age)
    local out = {}
    Append(out, [[\item ]])
    Append(out, age)
    Append(out, [[ (]])
    Append(out, Tr("x-years-ago", { 100 - age }))
    Append(out, [[): \\ \nameref{char} ]])
    Append(out, Tr("is") .. " ")
    Append(out, Tr(lifeStages[key]) .. ".")
    return table.concat(out)
end

local function generateExpected(depth, modification)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{char}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{char}]])
    Append(out, [[\label{char}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
    Append(out, [[\subparagraph{]] .. CapFirst(Tr("species-and-age")) .. [[:}]])
    Append(out, generateAppearance(depth, modification))
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item 0 (]] .. Tr("x-years-ago", { 100 }) .. [[): \\Born.]])
    for key, age in pairs(generateAgeAtLifestages(modification)) do
        Append(out, generateLifestageString(key, age))
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
    if modification == "mixing" then
        Append(out, [[\subparagraph{species-3-]] .. depth .. [[}]])
        Append(out, [[\label{species-3-]] .. depth .. [[}]])
    else
        Append(out, [[\subparagraph{species-1-]] .. depth .. [[}]])
        Append(out, [[\label{species-1-]] .. depth .. [[}]])
    end
    Append(out, [[\hspace{1cm}]])

    return out
end

local function setup()
    TexApi.setCurrentYear(100)
    TexApi.makeEntityPrimary("char")
    TexApi.addType { metatype = "other", type = "other" }
end

for depth = 1, 3 do
    for _, modification in pairs({ "none", "not-aging", "normal", "factor", "exponent", "both", "mixing" }) do
        newEntity("species-1-", depth)
        if modification == "not-aging" then
            TexApi.setAgeFactor(0)
        end
        if modification == "normal" then
            TexApi.setAgeFactor(1)
        end
        if modification == "factor" or modification == "both" or modification == "mixing" then
            TexApi.setAgeFactor(0.8)
        end
        if modification == "exponent" or modification == "both" or modification == "mixing" then
            TexApi.setAgeExponent(1.2)
        end
        newEntity("species-2-", depth)
        TexApi.setAgeFactor(1)
        newEntity("species-3-", depth)
        TexApi.setAgeModifierMixing("species-1-" .. depth, "species-2-" .. depth)

        TexApi.newEntity { label = "char", name = "char", type = "other" }
        if modification == "mixing" then
            TexApi.setSpecies("species-3-" .. depth)
        else
            TexApi.setSpecies("species-1-" .. depth)
        end
        TexApi.born { year = 0, event = "Born." }

        local name = "Age modifications " .. modification .. ", entity depth " .. depth
        local expected = generateExpected(depth, modification)
        AssertAutomatedChapters(name, expected, setup)
    end
end
