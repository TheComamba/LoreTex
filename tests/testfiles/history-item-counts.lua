TexApi.newEntity { type = "places", label = "test-1", name = "Test 1" }
TexApi.setDescriptor { descriptor = "descriptor", description = "description" }
TexApi.setDescriptor { descriptor = "subdescriptor", description =
[[\subparagraph{subdescription}\label{sublabel}]] }
local entity1 = CurrentEntity
TexApi.addHistory { year = 0, event = [[Concerns \nameref{test-1}.]] }
TexApi.addHistoryOnlyHere { year = 0, event = [[Concerns \reference{test-1}, but not \reference{test-2}.]] }

TexApi.newEntity { type = "places", label = "test-2", name = "Test 2" }
local entity2 = CurrentEntity
TexApi.addHistory { year = 0, event = [[Concerns \reference{test-1}, but not \reference{test-2}.\notconcerns{test-2}]] }

local historyItems1 = GetProtectedTableReferenceField(entity1, "historyItems")
local historyItemCount1 = #historyItems1
local historyItems2 = GetProtectedTableReferenceField(entity2, "historyItems")
local historyItemCount2 = #historyItems2

Assert("Count of history items for entity 1", 3, historyItemCount1)
Assert("Count of history items for entity 2", 0, historyItemCount2)
Assert("Count of history items for all entities", 3, #AllHistoryItems)
