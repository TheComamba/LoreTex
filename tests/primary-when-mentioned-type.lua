NewEntity("karl", "npcs", nil, "Karl")
SetDescriptor(CurrentEntity(), "species", "human")
SetDescriptor(CurrentEntity(), "Friend", [[\nameref{peter}]])
NewEntity("peter", "npcs", nil, "Peter")
SetDescriptor(CurrentEntity(), "species", "human")
NewEntity("human", "species", nil, "Human")
AddRef("karl", PrimaryRefs)

local function generateExpected(primaryType)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("characters")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{karl}]])
    if primaryType == "npcs" then
        Append(out, [[\item{} \nameref{peter}]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
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

    if primaryType == "species" then
        Append(out, [[\chapter{]] .. CapFirst(Tr("species")) .. [[}]])
        Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("species")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item{} \nameref{human}]])
        Append(out, [[\end{itemize}]])
        Append(out, [[\section{]] .. CapFirst(Tr("species")) .. [[}]])
        Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
        Append(out, [[\subsubsection{Human}]])
        Append(out, [[\label{human}]])
    end

    Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
    if primaryType ~= "species" then
        Append(out, [[\subparagraph{Human}]])
        Append(out, [[\label{human}]])
        Append(out, [[\hspace{1cm}]])
    end
    if primaryType ~= "npcs" then
        Append(out, [[\subparagraph{Peter}]])
        Append(out, [[\label{peter}]])
        Append(out, [[\hspace{1cm}]])
    end
    return out
end

local out = {}
local expected = {}

out = AutomatedChapters()
expected = generateExpected(nil)
Assert("two-npcs-one-mentioned", expected, out)

MakeTypePrimaryWhenMentioned("species")
out = AutomatedChapters()
expected = generateExpected("species")
Assert("species-are-primary-types", expected, out)

PrimaryRefWhenMentionedTypes = {}
MakeTypePrimaryWhenMentioned("npcs")
out = AutomatedChapters()
expected = generateExpected("npcs")
Assert("npcs-are-primary-types", expected, out)
