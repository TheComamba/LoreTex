local db = os.tmpname() .. ".db"

TexApi.newEntity { category = "test1", label = "test1", name = "Test1" }
TexApi.newEntity { category = "test2", label = "test2", name = "Test2" }
TexApi.addHistory { year = 0, content = [[Some event.]] }
TexApi.addParent { parentLabel = "test1", relationship = "Testrelationship" }
TexApi.writeLoreToDatabase(db)
Assert("Writing to database does not throw an error", HasError(), false)

TexApi.writeLoreToDatabase(db)
local hasError = HasError()
ResetState()
Assert("Writing to database twice does throw an error", hasError, true)
