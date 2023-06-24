TexApi.newEntity { type = "places", label = "locationLabel", name = "locationName" }
TexApi.newEntity { type = "other", label = "parentLabel", name = "parentName" }
TexApi.newEntity { type = "other", label = "testLabel", name = "testName" }
TexApi.setDescriptor { descriptor = "descriptor", description = "description" }
TexApi.setDescriptor { descriptor = "subdescriptor", description =
[[\subparagraph{subdescription}\label{subdescription}]] }
TexApi.setLocation("locationLabel")
TexApi.addParent { parentLabel = "parentLabel" }

local allEntitesBeforeRoundtrip = DeepCopy(AllEntities)
local entityColumns = EntitiesToColumns()
ResetState()
ColumnsToEntities()

for _, entityBefore in ipairs(allEntitesBeforeRoundtrip) do
    local label = GetProtectedStringField(entityBefore, "label")
    local entityAfter = GetEntity(label)
    Assert("FFI Conversion, comparing entity " .. label, entityBefore, entityAfter)
end
