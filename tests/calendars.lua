NewEntity("calendars", "test-1", nil, "Test 1")
AddMonth(CurrentEntity(), "Primus", 1)
AddMonth(CurrentEntity(), "Secundus", 100)
SetProtectedField(CurrentEntity(), "yearAbbreviation", "QT")

NewEntity("calendars", "test-2", nil, "Test 2")
AddMonth(CurrentEntity(), "Knulch", 20)
AddMonth(CurrentEntity(), "Wimmel", 300)
SetProtectedField(CurrentEntity(), "yearAbbreviation", "WX")
SetProtectedField(CurrentEntity(), "yearOffset", 200)

local expected = {}
local out = {}

expected = { Tr("day") .. [[ 17]] }
out = { DayString(17) }
Assert("no-format-specified-for-day", expected, out)


AddDayFmt("test-1")
expected = { Tr("day") .. [[ 17 / 17.Primus]] }
out = { DayString(17) }
Assert("one-format-specified-for-day", expected, out)

AddDayFmt("test-2")
expected = { Tr("day") .. [[ 17 / 17.Primus / 82.Wimmel]] }
out = { DayString(17) }
Assert("two-formats-specified-for-day", expected, out)

expected = { [[1801]] }
out = { YearString(1801) }
Assert("no-format-specified-for-year", expected, out)

AddYearFmt("test-1")
expected = { [[1801 QT]] }
out = { YearString(1801) }
Assert("one-format-specified-for-year", expected, out)

AddYearFmt("test-2")
expected = { [[1801 QT / 2001 WX]] }
out = { YearString(1801) }
Assert("two-formats-specified-for-year", expected, out)