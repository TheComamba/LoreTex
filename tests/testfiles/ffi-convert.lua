TexApi.newEntity { category = "places", label = "locationLabel", name = "locationName" }
TexApi.newEntity { category = "other", label = "parentLabel", name = "parentName" }

TexApi.newEntity { category = "other", label = "testLabel", name = "testName" }
TexApi.setDescriptor { descriptor = "descriptor", description = "description" }
TexApi.setDescriptor { descriptor = "subdescriptor", description =
[[\paragraph{subdescription}\label{subdescription}]] }
TexApi.setLocation("locationLabel")
TexApi.addParent { parentLabel = "parentLabel" }
TexApi.born { year = 223, content = [[\nameref{testLabel} is born, child of \nameref{parentLabel}.]] }
TexApi.setSpecies("species-1")

TexApi.newEntity { category = "NPCs", label = "some-npc", name = "Some NPC" }
local someList = { "First", "Second" }
local someMap = { Alpha = [[$\alpha$]], Beta = [[$\beta$]] }
TexApi.setDescriptor { descriptor = "Description", description = [[Mentions \nameref{testLabel}.]] }
TexApi.setDescriptor { descriptor = "Some List", description = someList }
TexApi.setDescriptor { descriptor = "Some Map", description = someMap }

TexApi.newEntity { category = "species", label = "species-1", name = "species-1" }
TexApi.setAgeFactor(0.8)
TexApi.setAgeExponent(1.2)
TexApi.newEntity { category = "species", label = "species-2", name = "species-2" }
TexApi.setAgeFactor(1)
TexApi.newEntity { category = "species", label = "species-3", name = "species-3" }
TexApi.setAgeModifierMixing("species-1", "species-2")
TexApi.newEntity { category = "species", label = "species-4", name = "species-4" }
TexApi.setAgeFactor(0)
TexApi.setAgeExponent(0)

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
