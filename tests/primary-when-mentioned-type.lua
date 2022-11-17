TexApi.newEntity { type = "npcs", label = "karl", name = "Karl" }
TexApi.setSpecies("human")
TexApi.setDescriptor { descriptor = "Friend", description = [[\nameref{peter}]] }
TexApi.newEntity { type = "npcs", label = "peter", name = "Peter" }
TexApi.setSpecies("human")
TexApi.newEntity { type = "species", label = "human", name = "Human" }
TexApi.setAgeFactor(0)
TexApi.mention("karl")

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
        Append(out, [[\subparagraph{]] .. CapFirst(Tr("species-and-age")) .. [[:}\nameref {human}.]])
        Append(out, [[\paragraph{Friend}]])
        Append(out, [[\nameref{peter}]])
        if primaryType == "npcs" then
            Append(out, [[\subsubsection{Peter}]])
            Append(out, [[\label{peter}]])
            Append(out, [[\paragraph{]] .. CapFirst(Tr("appearance")) .. [[}]])
            Append(out, [[\subparagraph{]] .. CapFirst(Tr("species-and-age")) .. [[:}\nameref {human}.]])
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

local out = {}
local expected = {}

PrimaryRefWhenMentionedTypes = {}
out = TexApi.automatedChapters()
expected = generateExpected(nil, false)
Assert("one-only-mentioned-npc", expected, out)

PrimaryRefWhenMentionedTypes = {}
MakeTypePrimaryWhenMentioned("species")
out = TexApi.automatedChapters()
expected = generateExpected("species")
Assert("species-are-primary-types-npc-is-only-mentioned", expected, out)

PrimaryRefWhenMentionedTypes = {}
MakeTypePrimaryWhenMentioned("npcs")
out = TexApi.automatedChapters()
expected = generateExpected("npcs", false)
Assert("npcs-are-primary-types-one-is-only-mentioned", expected, out)

TexApi.makeEntityPrimary("karl")

PrimaryRefWhenMentionedTypes = {}
out = TexApi.automatedChapters()
expected = generateExpected(nil, true)
Assert("two-npcs-one-primary", expected, out)

PrimaryRefWhenMentionedTypes = {}
MakeTypePrimaryWhenMentioned("species")
out = TexApi.automatedChapters()
expected = generateExpected("species", true)
Assert("species-are-primary-types-one-npc-explicitly-referenced", expected, out)

PrimaryRefWhenMentionedTypes = {}
MakeTypePrimaryWhenMentioned("npcs")
out = TexApi.automatedChapters()
expected = generateExpected("npcs", true)
Assert("npcs-are-primary-types-one-explicitly-referenced", expected, out)
