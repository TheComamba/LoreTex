NewEntity("test-place-1", "place", nil, "Test Place 1")
NewCharacter("test-char-1", nil, "Test Char 1")
DefaultLocation = "lalaland"
NewEntity("test-place-2", "place", nil, "Test Place 2")
NewCharacter("test-char-2", nil, "Test Char 2")
Assert("Default Location Place 1", nil, GetEntity("test-place-1", AllEntities)["location"])
Assert("Default Location Char 1", nil, GetEntity("test-char-1", AllEntities)["location"])
Assert("Default Location Place 2", "lalaland", GetEntity("test-place-2", AllEntities)["location"])
Assert("Default Location Char 2", "lalaland", GetEntity("test-char-2", AllEntities)["location"])
