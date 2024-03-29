local function entitySetup(setLocations)
    TexApi.newEntity { category = "other", label = "orga", name = "Orga" }
    local orga = CurrentEntity

    TexApi.newEntity { category = "places", label = "place-1", name = "Place 1" }
    TexApi.addParent { parentLabel = "orga" }

    TexApi.newEntity { category = "places", label = "place-2", name = "Place 2" }
    TexApi.addParent { parentLabel = "orga", relationship = "Hometown" }
    local place2 = CurrentEntity

    TexApi.newEntity { category = "other", label = "orga-2", name = "Orga 2" }
    TexApi.addParent { parentLabel = "place-1", relationship = "Rulers" }
    local orga2 = CurrentEntity

    if setLocations then
        SetLocation(orga, GetEntity("place-3"))
        SetLocation(orga2, GetEntity("place-1"))
        SetLocation(place2, GetEntity("place-4"))
    end
end

local function refSetup()
    TexApi.showSecrets()
    TexApi.makeEntityPrimary("orga")
    TexApi.makeEntityPrimary("place-1")
    TexApi.makeEntityPrimary("place-2")
    TexApi.makeEntityPrimary("orga-2")
end

local function generateOrga1(areLocationsSet)
    local out = {}
    Append(out, [[\subsection{Orga}]])
    Append(out, [[\label{orga}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ Places}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{place-1}]])
    if areLocationsSet then
        Append(out, [[\item \nameref{place-2} (Hometown, ]] .. Tr("located_in") .. [[ \nameref{place-4})]])
    else
        Append(out, [[\item \nameref{place-2} (Hometown)]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function generateOrga2()
    local out = {}
    Append(out, [[\subsection{Orga 2}]])
    Append(out, [[\label{orga-2}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item Rulers ]] .. Tr("of") .. [[ \nameref{place-1}.]])
    Append(out, [[\end{itemize}]])
    return out
end

local function generateExpected(areLocationsSet)
    local out = {}
    Append(out, [[\chapter{Other}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Other}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{orga}]])
    Append(out, [[\item \nameref{orga-2}]])
    Append(out, [[\end{itemize}]])
    if areLocationsSet then
        Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Place 1}]])
        Append(out, generateOrga2())
        Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Place 3}]])
    else
        Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    end

    Append(out, generateOrga1(areLocationsSet))
    if not areLocationsSet then
        Append(out, generateOrga2())
    end

    Append(out, [[\chapter{Places}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Places}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{place-1}]])
    Append(out, [[\item \nameref{place-2}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(out, [[\subsection{Place 1}]])
    Append(out, [[\label{place-1}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ Other}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{orga-2} (Rulers)]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{orga}.]])
    Append(out, [[\end{itemize}]])
    if areLocationsSet then
        Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Place 4}]])
    end
    Append(out, [[\subsection{Place 2}]])
    Append(out, [[\label{place-2}]])
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item Hometown ]] .. Tr("of") .. [[ \nameref{orga}.]])
    Append(out, [[\end{itemize}]])
    if areLocationsSet then
        Append(out, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])
        Append(out, [[\subparagraph{Place 4}]])
        Append(out, [[\label{place-4}]])
        Append(out, [[\hspace{1cm}]])
    end
    return out
end

entitySetup(false)
local expected = generateExpected(false)
AssertAutomatedChapters("entities-with-associations", expected, refSetup)

TexApi.newEntity { category = "places", label = "place-3", name = "Place 3" }
TexApi.newEntity { category = "places", label = "place-4", name = "Place 4" }
entitySetup(true)
local expected = generateExpected(true)
AssertAutomatedChapters("entities-with-associations-and-locations", expected, refSetup)
