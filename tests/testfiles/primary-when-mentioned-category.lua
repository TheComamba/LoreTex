local function setup()
    TexApi.newEntity { category = "NPCs", label = "karl", name = "Karl" }
    TexApi.setSpecies("human")
    TexApi.setDescriptor { descriptor = "Friend", description = [[\nameref{peter}]] }
    TexApi.newEntity { category = "NPCs", label = "peter", name = "Peter" }
    TexApi.setSpecies("human")
    TexApi.newEntity { category = "species", label = "human", name = "Human" }
    TexApi.setAgeFactor(0)
end

local function generateExpected(primaryCategory, isKarlReferenced)
    local out = {}
    if primaryCategory == "NPCs" or isKarlReferenced then
        Append(out, [[\chapter{NPCs}]])
        Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item \nameref{karl}]])
        if primaryCategory == "NPCs" then
            Append(out, [[\item \nameref{peter}]])
        end
        Append(out, [[\end{itemize}]])
        Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
        Append(out, [[\subsection{Karl}]])
        Append(out, [[\label{karl}]])
        Append(out, [[\subsubsection{]] .. CapFirst(Tr("appearance")) .. [[}]])
        Append(out, [[\paragraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]])
        Append(out, [[\nameref {human}.]])
        Append(out, [[\subsubsection{Friend}]])
        Append(out, [[\nameref{peter}]])
        if primaryCategory == "NPCs" then
            Append(out, [[\subsection{Peter}]])
            Append(out, [[\label{peter}]])
            Append(out, [[\subsubsection{]] .. CapFirst(Tr("appearance")) .. [[}]])
            Append(out, [[\paragraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]])
            Append(out, [[\nameref {human}.]])
        end
    end

    if primaryCategory == "species" and isKarlReferenced then
        Append(out, [[\chapter{Species}]])
        Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Species}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item \nameref{human}]])
        Append(out, [[\end{itemize}]])
        Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
        Append(out, [[\subsection{Human}]])
        Append(out, [[\label{human}]])
    end

    Append(out, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])

    if primaryCategory ~= "species" then
        if isKarlReferenced or primaryCategory == "NPCs" then
            Append(out, [[\subparagraph{Human}]])
            Append(out, [[\label{human}]])
            Append(out, [[\hspace{1cm}]])
        end
    end

    if primaryCategory ~= "NPCs" then
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
    TexApi.makeCategoryPrimaryWhenMentioned("species")
end

setup()
expected = generateExpected("species")
AssertAutomatedChapters("species-are-primary-categorys-npc-is-only-mentioned", expected, refSetup2)

local function refSetup3()
    TexApi.mention("karl")
    TexApi.makeCategoryPrimaryWhenMentioned("NPCs")
end

setup()
expected = generateExpected("NPCs", false)
AssertAutomatedChapters("NPCs-are-primary-categorys-one-is-only-mentioned", expected, refSetup3)

local function refSetup4()
    TexApi.mention("karl")
    TexApi.makeEntityPrimary("karl")
end

setup()
expected = generateExpected(nil, true)
AssertAutomatedChapters("two-NPCs-one-primary", expected, refSetup4)

local function refSetup5()
    TexApi.mention("karl")
    TexApi.makeEntityPrimary("karl")
    TexApi.makeCategoryPrimaryWhenMentioned("species")
end

setup()
expected = generateExpected("species", true)
AssertAutomatedChapters("species-are-primary-categorys-one-npc-explicitly-referenced", expected, refSetup5)

local function refSetup6()
    TexApi.mention("karl")
    TexApi.makeEntityPrimary("karl")
    TexApi.makeCategoryPrimaryWhenMentioned("NPCs")
end

setup()
expected = generateExpected("NPCs", true)
AssertAutomatedChapters("NPCs-are-primary-categorys-one-explicitly-referenced", expected, refSetup6)
