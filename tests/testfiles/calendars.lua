TexApi.setDaysPerYear(200)

TexApi.newEntity { type = "calendars", label = "test-1", name = "Test 1" }
TexApi.addMonth { month = "Primus", firstDay = 1 }
TexApi.addMonth { month = "Secundus", firstDay = 100 }
TexApi.setYearAbbreviation("QT")

TexApi.newEntity { type = "calendars", label = "test-2", name = "Test 2" }
TexApi.addMonth { month = "Knulch", firstDay = 20 }
TexApi.addMonth { month = "Wimmel", firstDay = 150 }
TexApi.setYearAbbreviation("WX")
TexApi.setYearOffset(200)

local expected = {}
local out = {}

expected = { Tr("day") .. [[ 17]] }
out = { DayString(17) }
Assert("no-format-specified-for-day", expected, out)


TexApi.addDayFmt("test-1")
expected = { Tr("day") .. [[ 17 / 17.Primus]] }
out = { DayString(17) }
Assert("one-format-specified-for-day", expected, out)

TexApi.addDayFmt("test-2")
expected = { Tr("day") .. [[ 17 / 17.Primus / 68.Wimmel]] }
out = { DayString(17) }
Assert("two-formats-specified-for-day", expected, out)

expected = { [[1801]] }
out = { YearString(1801) }
Assert("no-format-specified-for-year", expected, out)

TexApi.addYearFmt("test-1")
expected = { [[1801 QT]] }
out = { YearString(1801) }
Assert("one-format-specified-for-year", expected, out)

TexApi.addYearFmt("test-2")
expected = { [[1801 QT / 2001 WX]] }
out = { YearString(1801) }
Assert("two-formats-specified-for-year", expected, out)
