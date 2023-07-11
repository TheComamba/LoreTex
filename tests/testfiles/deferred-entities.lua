TexApi.newEntity { label = "unimportant", type = "places", name = "Unimportant" }
TexApi.addHistory { year = 0, event = [[Mentions \nameref{deferred-entity-1}.]] }
TexApi.addHistory { year = 0, event = [[Mentions \nameref{deferred-entity-2-alias}.]] }
TexApi.newEntity { label = "deferred-entity-1", type = "places", name = "Deferred 1" }
TexApi.newEntity { label = "deferred-entity-2", type = "places", name = "Deferred 2" }
TexApi.setDescriptor { descriptor = "Alias", description = [[\label{deferred-entity-2-alias}]] }

local function setup1()
    TexApi.setCurrentYear(0)
    TexApi.makeEntityPrimary("deferred-entity-1")
    TexApi.makeEntityPrimary("deferred-entity-2")
    TexApi.addType { metatype = "places", type = "places" }
end
local expected = {}
Append(expected, [[\chapter{Places}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Places}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{deferred-entity-2-alias}]])
Append(expected, [[\item \nameref{deferred-entity-1}]])
Append(expected, [[\item \nameref{deferred-entity-2}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])

Append(expected, [[\subsection{Deferred 1}]])
Append(expected, [[\label{deferred-entity-1}]])
Append(expected, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item 0 (]] .. Tr("this_year") .. [[):\\Mentions \nameref{deferred-entity-1}.]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\subsection{Deferred 2}]])
Append(expected, [[\label{deferred-entity-2}]])
Append(expected, [[\subsubsection{Alias}]])
Append(expected, [[\label{deferred-entity-2-alias}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item 0 (]] .. Tr("this_year") .. [[):\\Mentions \nameref{deferred-entity-2-alias}.]])
Append(expected, [[\end{itemize}]])

AssertAutomatedChapters("Deferred Entities", expected, setup1)

TexApi.newEntity { type = "NPCs", label = "some-npc", name = "Some NPC" }
TexApi.setLocation("some-place")
TexApi.addParent { parentLabel = "orga-sublabel", relationship = "Code-Cleaner" }
TexApi.newEntity { type = "places", label = "some-place", name = "Some Place" }
TexApi.newEntity { type = "other", label = "some-orga", name = "Some Orga" }
TexApi.setDescriptor { descriptor = "Orga Sublabel", description = [[\label{orga-sublabel}]] }

local function setup2()
    TexApi.makeEntityPrimary("some-npc")
    TexApi.addType { metatype = "characters", type = "NPCs" }
end

expected = {}
Append(expected, [[\chapter{NPCs}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{some-npc}]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Some Place}]])
Append(expected, [[\subsection{Some NPC}]])
Append(expected, [[\label{some-npc}]])
Append(expected, [[\subsubsection{]] .. CapFirst(Tr("affiliations")) .. [[}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item Code-Cleaner ]] .. Tr("of") .. [[ \nameref{orga-sublabel}.]])
Append(expected, [[\end{itemize}]])

Append(expected, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])
Append(expected, [[\subparagraph{Orga Sublabel}]])
Append(expected, [[\label{orga-sublabel}]])
Append(expected, [[\hspace{1cm}]])

AssertAutomatedChapters("Deferred Location and Association", expected, setup2)

local function defineCalendar()
    TexApi.newEntity { type = "calendars", label = "test-1", name = "Test 1" }
    TexApi.addMonth { month = "Primus", firstDay = 1 }
    TexApi.addMonth { month = "Secundus", firstDay = 100 }
    TexApi.setYearAbbreviation("QT")
    TexApi.setYearOffset(200)
end

local out = {}

ResetState()
TexApi.addDayFmt("test-1")
defineCalendar()
expected = { Tr("day") .. [[17 / 17.Primus]] }
out = { DayString(17) }
Assert("Deferred Calendar (Day)", expected, out)

ResetState()
TexApi.addYearFmt("test-1")
defineCalendar()
expected = { [[2001 QT]] }
out = { YearString(1801) }
Assert("Deferred Calendar (Year)", expected, out)

ResetState()
TexApi.newEntity { type = "places", label = "some-place", name = "Some Place" }
TexApi.addHistory { yearFmt = "test-1", year = 0, event = "Some event." }
defineCalendar()
out = GetEntity("some-place")
out = GetProtectedTableReferenceField(out, "historyItems")[1]
Assert("Deferred Calendar (History)", false, IsEmpty(out))
