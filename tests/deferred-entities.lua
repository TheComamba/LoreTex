TexApi.setCurrentYear(0)
TexApi.newEntity { label = "unimportant", type = "places", name = "Unimportant" }
TexApi.addHistory { year = 0, event = [[Mentions \nameref{deferred-entity-1}.]] }
TexApi.addHistory { year = 0, event = [[Mentions \nameref{deferred-entity-2-alias}.]] }
TexApi.newEntity { label = "deferred-entity-1", type = "places", name = "Deferred 1" }
TexApi.newEntity { label = "deferred-entity-2", type = "places", name = "Deferred 2" }
TexApi.setDescriptor { descriptor = "Alias", description = [[\label{deferred-entity-2-alias}]] }
TexApi.makeEntityPrimary("deferred-entity-1")
TexApi.makeEntityPrimary("deferred-entity-2")
local expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("places")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{deferred-entity-2-alias}]])
Append(expected, [[\item \nameref{deferred-entity-1}]])
Append(expected, [[\item \nameref{deferred-entity-2}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])

Append(expected, [[\subsubsection{Deferred 1}]])
Append(expected, [[\label{deferred-entity-1}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item 0 (]] .. Tr("this-year") .. [[):\\Mentions \nameref{deferred-entity-1}.]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsubsection{Deferred 2}]])
Append(expected, [[\label{deferred-entity-2}]])
Append(expected, [[\paragraph{Alias}]])
Append(expected, [[\label{deferred-entity-2-alias}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item 0 (]] .. Tr("this-year") .. [[):\\Mentions \nameref{deferred-entity-2-alias}.]])
Append(expected, [[\end{itemize}]])

local out = TexApi.automatedChapters()

Assert("Deferred Entities", expected, out)

ResetEnvironment()

TexApi.newEntity { type = "npcs", label = "some-npc", name = "Some NPC" }
TexApi.setLocation("some-place")
TexApi.addParent { parentLabel = "orga-sublabel", relationship = "Code-Cleaner" }
TexApi.makeEntityPrimary("some-npc")
TexApi.newEntity { type = "places", label = "some-place", name = "Some Place" }
TexApi.newEntity { type = "organisations", label = "some-orga", name = "Some Orga" }
TexApi.setDescriptor { descriptor = "Orga Sublabel", description = [[\label{orga-sublabel}]] }

expected = {}
Append(expected, [[\chapter{]] .. CapFirst(Tr("characters")) .. [[}]])
Append(expected, [[\section{]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("npcs")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{some-npc}]])
Append(expected, [[\end{itemize}]])


Append(expected, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Some Place}]])
Append(expected, [[\subsubsection{Some NPC}]])
Append(expected, [[\label{some-npc}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item Code-Cleaner ]] .. Tr("of") .. [[ \nameref{orga-sublabel}.]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
Append(expected, [[\subparagraph{Orga Sublabel}]])
Append(expected, [[\label{orga-sublabel}]])
Append(expected, [[\hspace{1cm}]])

local out = TexApi.automatedChapters()

Assert("Deferred Location and Association", expected, out)

local function defineCalendar()
    TexApi.newEntity { type = "calendars", label = "test-1", name = "Test 1" }
    TexApi.addMonth { month = "Primus", firstDay = 1 }
    TexApi.addMonth { month = "Secundus", firstDay = 100 }
    TexApi.setYearAbbreviation("QT")
    TexApi.setYearOffset(200)
end

ResetEnvironment()
TexApi.addDayFmt("test-1")
defineCalendar()
expected = { Tr("day") .. [[17 / 17.Primus]] }
out = { DayString(17) }
Assert("Deferred Calendar (Day)", expected, out)

ResetEnvironment()
TexApi.addYearFmt("test-1")
defineCalendar()
expected = { [[2001 QT]] }
out = { YearString(1801) }
Assert("Deferred Calendar (Year)", expected, out)

ResetEnvironment()
TexApi.newEntity { type = "places", label = "some-place", name = "Some Place" }
TexApi.addHistory { yearFmt = "test-1", year = 0, event = "Some event." }
defineCalendar()
out = GetEntity("some-place")
out = GetProtectedTableField(out, "historyItems")[1]
Assert("Deferred Calendar (History)", false, IsEmpty(out))
