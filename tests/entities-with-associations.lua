NewEntity("organisations", "orga", nil, "Orga")
local orga = CurrentEntity()

NewEntity("places", "place-1", nil, "Place 1")
AddParent(CurrentEntity(), "orga")

NewEntity("places", "place-2", nil, "Place 2")
local place2 = CurrentEntity()
AddParent(place2, "orga", "Hometown")

NewEntity("organisations", "orga-2", nil, "Orga 2")
local orga2 = CurrentEntity()
AddParent(orga2, "place-1", "Rulers")

AddAllEntitiesToPrimaryRefs()
local out = AutomatedChapters()

local function generateOrga1(areLocationsSet)
    local out = {}
    Append(out, [[\subsubsection{Orga}]])
    Append(out, [[\label{orga}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("places") .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{place-1}]])
    if areLocationsSet then
        Append(out, [[\item{} \nameref{place-2} (Hometown, ]] .. Tr("in") .. [[ \nameref{place-4})]])
    else
        Append(out, [[\item{} \nameref{place-2} (Hometown)]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function generateOrga2()
    local out = {}
    Append(out, [[\subsubsection{Orga 2}]])
    Append(out, [[\label{orga-2}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} Rulers ]] .. Tr("of") .. [[ \nameref{place-1}.]])
    Append(out, [[\end{itemize}]])
    return out
end

local function generateExpected(areLocationsSet)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("associations")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("organisations")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("organisations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{orga}]])
    Append(out, [[\item{} \nameref{orga-2}]])
    Append(out, [[\end{itemize}]])
    if areLocationsSet then
        Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Place 1}]])
        Append(out, generateOrga2())
        Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Place 3}]])
    else
        Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    end

    Append(out, generateOrga1(areLocationsSet))
    if not areLocationsSet then
        Append(out, generateOrga2())
    end

    Append(out, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. " " .. CapFirst(Tr("places")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{place-1}]])
    Append(out, [[\item{} \nameref{place-2}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Place 1}]])
    Append(out, [[\label{place-1}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. " " .. Tr("organisations") .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{orga-2} (Rulers)]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{orga}.]])
    Append(out, [[\end{itemize}]])
    if areLocationsSet then
        Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Place 4}]])
    end
    Append(out, [[\subsubsection{Place 2}]])
    Append(out, [[\label{place-2}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} Hometown ]] .. Tr("of") .. [[ \nameref{orga}.]])
    Append(out, [[\end{itemize}]])
    if areLocationsSet then
        Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
        Append(out, [[\subparagraph{Place 4}]])
        Append(out, [[\label{place-4}]])
        Append(out, [[\hspace{1cm}]])
    end
    return out
end

local expected = generateExpected(false)
Assert("entities-with-associations", expected, out)

NewEntity("places", "place-3", nil, "Place 3")
NewEntity("places", "place-4", nil, "Place 4")
SetLocation(orga, "place-3")
SetLocation(orga2, "place-1")
SetLocation(place2, "place-4")

out = AutomatedChapters()

local expected = generateExpected(true)
Assert("entities-with-associations-and-locations", expected, out)
