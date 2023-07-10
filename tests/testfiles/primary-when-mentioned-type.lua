local function setup()
    TexApi.newEntity { type = "NPCs", label = "karl", name = "Karl" }
    TexApi.setSpecies("human")
    TexApi.setDescriptor { descriptor = "Friend", description = [[\nameref{peter}]] }
    TexApi.newEntity { type = "NPCs", label = "peter", name = "Peter" }
    TexApi.setSpecies("human")
    TexApi.newEntity { type = "species", label = "human", name = "Human" }
    TexApi.setAgeFactor(0)
end

local function generateExpected(primaryType, isKarlReferenced)
    local out = {}
    if primaryType == "NPCs" or isKarlReferenced then
        Append(out, [[\chapter{Characters}]])
        Append(out, [[\section{NPCs}]])
        Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item \nameref{karl}]])
        if primaryType == "NPCs" then
            Append(out, [[\item \nameref{peter}]])
        end
        Append(out, [[\end{itemize}]])
        Append(out, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
        Append(out, [[\subsubsection{Karl}]])
        Append(out, [[\label{karl}]])
        Append(out, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
        Append(out, [[\subparagraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]])
        Append(out, [[\nameref {human}.]])
        Append(out, [[\paragraph{Friend}]])
        Append(out, [[\nameref{peter}]])
        if primaryType == "NPCs" then
            Append(out, [[\subsubsection{Peter}]])
            Append(out, [[\label{peter}]])
            Append(out, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
            Append(out, [[\subparagraph{]] .. CapFirst(Tr("species_and_age")) .. [[:}]])
            Append(out, [[\nameref {human}.]])
        end
    end

    if primaryType == "species" and isKarlReferenced then
        Append(out, [[\chapter{Peoples}]])
        Append(out, [[\section{Species}]])
        Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ Species}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item \nameref{human}]])
        Append(out, [[\end{itemize}]])
        Append(out, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
        Append(out, [[\subsubsection{Human}]])
        Append(out, [[\label{human}]])
    end

    Append(out, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])

    if primaryType ~= "species" then
        if isKarlReferenced or primaryType == "NPCs" then
            Append(out, [[\subparagraph{Human}]])
            Append(out, [[\label{human}]])
            Append(out, [[\hspace{1cm}]])
        end
    end

    if primaryType ~= "NPCs" then
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

local function typeSetup()
    TexApi.addType { metatype = "characters", type = "NPCs" }
    TexApi.addType { metatype = "peoples", type = "species" }
end

local function refSetup1()
    TexApi.mention("karl")
    typeSetup()
end

setup()
expected = generateExpected(nil, false)
AssertAutomatedChapters("one-only-mentioned-npc", expected, refSetup1)

local function refSetup2()
    TexApi.mention("karl")
    TexApi.makeTypePrimaryWhenMentioned("species")
    typeSetup()
end

setup()
expected = generateExpected("species")
AssertAutomatedChapters("species-are-primary-types-npc-is-only-mentioned", expected, refSetup2)

local function refSetup3()
    TexApi.mention("karl")
    TexApi.makeTypePrimaryWhenMentioned("NPCs")
    typeSetup()
end

setup()
expected = generateExpected("NPCs", false)
AssertAutomatedChapters("NPCs-are-primary-types-one-is-only-mentioned", expected, refSetup3)

local function refSetup4()
    TexApi.mention("karl")
    TexApi.makeEntityPrimary("karl")
    typeSetup()
end

setup()
expected = generateExpected(nil, true)
AssertAutomatedChapters("two-NPCs-one-primary", expected, refSetup4)

local function refSetup5()
    TexApi.mention("karl")
    TexApi.makeEntityPrimary("karl")
    TexApi.makeTypePrimaryWhenMentioned("species")
    typeSetup()
end

setup()
expected = generateExpected("species", true)
AssertAutomatedChapters("species-are-primary-types-one-npc-explicitly-referenced", expected, refSetup5)

local function refSetup6()
    TexApi.mention("karl")
    TexApi.makeEntityPrimary("karl")
    TexApi.makeTypePrimaryWhenMentioned("NPCs")
    typeSetup()
end

setup()
expected = generateExpected("NPCs", true)
AssertAutomatedChapters("NPCs-are-primary-types-one-explicitly-referenced", expected, refSetup6)
