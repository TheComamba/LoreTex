local function setup()
    TexApi.newEntity { type = "npcs", label = "karl", name = "Karl" }
    TexApi.setSpecies("human")
    TexApi.setDescriptor { descriptor = "Friend", description = [[\nameref{peter}]] }
    TexApi.newEntity { type = "npcs", label = "peter", name = "Peter" }
    TexApi.setSpecies("human")
    TexApi.newEntity { type = "species", label = "human", name = "Human" }
    TexApi.setAgeFactor(0)
end

local function generateExpected(primaryType, isKarlReferenced)
    local out = {}
    if primaryType == "npcs" or isKarlReferenced then
        Append(out, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
        Append(out, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
        Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item \nameref{karl}]])
        if primaryType == "npcs" then
            Append(out, [[\item \nameref{peter}]])
        end
        Append(out, [[\end{itemize}]])
        Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
        Append(out, [[\subsubsection{Karl}]])
        Append(out, [[\label{karl}]])
        Append(out, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
        Append(out, [[\subparagraph{]] .. CapFirst(Tr("species-and-age")) .. [[:}]])
        Append(out, [[\nameref {human}.]])
        Append(out, [[\paragraph{Friend}]])
        Append(out, [[\nameref{peter}]])
        if primaryType == "npcs" then
            Append(out, [[\subsubsection{Peter}]])
            Append(out, [[\label{peter}]])
            Append(out, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
            Append(out, [[\subparagraph{]] .. CapFirst(Tr("species-and-age")) .. [[:}]])
            Append(out, [[\nameref {human}.]])
        end
    end

    if primaryType == "species" and isKarlReferenced then
        Append(out, [[\chapter{]] .. CapFirst(Tr("peoples")) .. [[}]])
        Append(out, [[\section{]] .. CapFirst(Tr("species")) .. [[}]])
        Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("species")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item \nameref{human}]])
        Append(out, [[\end{itemize}]])
        Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
        Append(out, [[\subsubsection{Human}]])
        Append(out, [[\label{human}]])
    end

    Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])

    if primaryType ~= "species" then
        if isKarlReferenced or primaryType == "npcs" then
            Append(out, [[\subparagraph{Human}]])
            Append(out, [[\label{human}]])
            Append(out, [[\hspace{1cm}]])
        end
    end

    if primaryType ~= "npcs" then
        if isKarlReferenced then
            Append(out, [[\subparagraph{Peter}]])
            Append(out, [[\label{peter}]])
            Append(out, [[\hspace{1cm}]])
        else
            Append(out, [[\subparagraph{Karl}]])
            Append(out, [[\label{karl}]])
            Append(out, [[\hspace{1cm}]])
        end
    end

    return out
end

local expected = {}

local function refSetup1()
    TexApi.mention("karl")
end

setup()
expected = generateExpected(nil, false)
AssertAutomatedChapters("one-only-mentioned-npc", expected, refSetup1)

local function refSetup2()
    TexApi.mention("karl")
    TexApi.makeTypePrimaryWhenMentioned("species")
end

setup()
expected = generateExpected("species")
AssertAutomatedChapters("species-are-primary-types-npc-is-only-mentioned", expected, refSetup2)

local function refSetup3()
    TexApi.mention("karl")
    TexApi.makeTypePrimaryWhenMentioned("npcs")
end

setup()
expected = generateExpected("npcs", false)
AssertAutomatedChapters("npcs-are-primary-types-one-is-only-mentioned", expected, refSetup3)

local function refSetup4()
    TexApi.mention("karl")
    TexApi.makeEntityPrimary("karl")
end

setup()
expected = generateExpected(nil, true)
AssertAutomatedChapters("two-npcs-one-primary", expected, refSetup4)

local function refSetup5()
    TexApi.mention("karl")
    TexApi.makeEntityPrimary("karl")
    TexApi.makeTypePrimaryWhenMentioned("species")
end

setup()
expected = generateExpected("species", true)
AssertAutomatedChapters("species-are-primary-types-one-npc-explicitly-referenced", expected, refSetup5)

local function refSetup6()
    TexApi.mention("karl")
    TexApi.makeEntityPrimary("karl")
    TexApi.makeTypePrimaryWhenMentioned("npcs")
end

setup()
expected = generateExpected("npcs", true)
AssertAutomatedChapters("npcs-are-primary-types-one-explicitly-referenced", expected, refSetup6)
