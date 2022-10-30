NewEntity("calendars", "test-1", nil, "Test 1")
AddMonth(CurrentEntity(), "Primus", 1)
AddMonth(CurrentEntity(), "Secundus", 100)

NewEntity("calendars", "test-2", nil, "Test 2")
AddMonth(CurrentEntity(), "Knulch", 20)
AddMonth(CurrentEntity(), "Wimmel", 300)

local expected = {}
local out = {}

expected = { [[17]]}
out = {Date(17)}
Assert("no-format-specified", expected, out)

AddDateFmt("test-1")
expected = {[[17 / 17.Primus]]}
out = {Date(17)}
Assert("one-format-specified", expected, out)


AddDateFmt("test-2")
expected = {[[17 / 17.Primus / 82.Wimmel]]}
out = {Date(17)}
Assert("two-formats-specified", expected, out)