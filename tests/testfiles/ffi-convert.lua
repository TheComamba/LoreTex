TexApi.newEntity { type = "places", label = "locationLabel", name = "locationName" }
TexApi.newEntity { type = "other", label = "parentLabel", name = "parentName" }

TexApi.newEntity { type = "other", label = "testLabel", name = "testName" }
TexApi.setDescriptor { descriptor = "descriptor", description = "description" }
TexApi.setDescriptor { descriptor = "subdescriptor", description =
[[\subparagraph{subdescription}\label{subdescription}]] }
TexApi.setLocation("locationLabel")
TexApi.addParent { parentLabel = "parentLabel" }
TexApi.born { year = 223, event = [[\nameref{testLabel} is born, child of \nameref{parentLabel}.]] }

TexApi.newEntity { type = "npcs", label = "some-npc", name = "Some NPC" }
TexApi.setDescriptor { descriptor = "Description", description = [[Mentions \nameref{testLabel}.]] }

local allEntitesBeforeRoundtrip = DeepCopy(AllEntities)
local allHistoryItemsBeforeRoundtrip = DeepCopy(AllHistoryItems)

local entityColumns = GetEntityColumns()
local historyItemColumns = GetHistoryItemColumns()
local relationshipColumns = GetRelationshipColumns()
ResetState()

EntitiesFromColumns(entityColumns)
HistoryItemsFromColumns(historyItemColumns)
RelationshipsFromColumns(relationshipColumns)

for _, entityBefore in ipairs(allEntitesBeforeRoundtrip) do
    local label = GetProtectedStringField(entityBefore, "label")
    local entityAfter = GetEntity(label)
    Assert("FFI Conversion, comparing entity " .. label, entityBefore, entityAfter)
end

for i, historyItemBefore in ipairs(allHistoryItemsBeforeRoundtrip) do
    local historyItemAfter = AllHistoryItems[i]
    Assert("FFI Conversion, comparing history item " .. i, historyItemBefore, historyItemAfter)
end
