TexApi.newEntity { type = "places", label = "locationLabel", name = "locationName" }
TexApi.newEntity { type = "other", label = "parentLabel", name = "parentName" }

TexApi.newEntity { type = "other", label = "testLabel", name = "testName" }
TexApi.setDescriptor { descriptor = "descriptor", description = "description" }
TexApi.setDescriptor { descriptor = "subdescriptor", description =
[[\subparagraph{subdescription}\label{subdescription}]] }
TexApi.setLocation("locationLabel")
TexApi.addParent { parentLabel = "parentLabel" }
TexApi.born { year = 223, event = [[\nameref{testLabel} is born, child of \nameref{parentLabel}.]] }

local allEntitesBeforeRoundtrip = DeepCopy(AllEntities)
local allHistoryItemsBeforeRoundtrip = DeepCopy(AllHistoryItems)

local entityColumns = GetEntityColumns()
local historyItemColumns = GetHistoryItemColumns()
ResetState()

EntitiesFromColumns(entityColumns)
HistoryItemsFromColumns(historyItemColumns)

for _, entityBefore in ipairs(allEntitesBeforeRoundtrip) do
    local label = GetProtectedStringField(entityBefore, "label")
    local entityAfter = GetEntity(label)
    Assert("FFI Conversion, comparing entity " .. label, entityBefore, entityAfter)
end

for i, historyItemBefore in ipairs(allHistoryItemsBeforeRoundtrip) do
    local historyItemAfter = AllHistoryItems[i]
    Assert("FFI Conversion, comparing history item " .. i, historyItemBefore, historyItemAfter)
end
