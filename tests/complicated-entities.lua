NewEntity("test-region", "place", nil, "Test Region")

NewEntity("test-city-1", "place", nil, "Test City 1")
SetDescriptor(CurrentEntity(), "location", "test-region")

NewEntity("test-city-2", "place", nil, "Test City 2")
SetDescriptor(CurrentEntity(), "location", "test-region")

NewEntity("test-species", "species", nil, "Test Species")

NewEntity("test-npc-1", "npc", nil, "Test NPC 1")
SetDescriptor(CurrentEntity(), "location", "test-city-1")
SetDescriptor(CurrentEntity(), "species", "test-species")

NewEntity("test-npc-2", "npc", nil, "Test NPC 2")
SetDescriptor(CurrentEntity(), "location", "test-city-2")
SetDescriptor(CurrentEntity(), "species", "test-species")

AddAllEntitiesToPrimaryRefs()

local out = AutomatedChapters()

local expected = {} --[[]]

Assert("complicated-entities", expected, out)