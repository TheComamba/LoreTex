NewEntity("places", "test-place-1", nil, "Test Place 1")
Assert("Default Location Place 1", nil, CurrentEntity()["location"])
NewCharacter("test-char-1", nil, "Test Char 1")
Assert("Default Location Char 1", nil, CurrentEntity()["location"])
DefaultLocation = "lalaland"
NewEntity("places", "test-place-2", nil, "Test Place 2")
Assert("Default Location Place 2", "lalaland", CurrentEntity()["location"])
NewCharacter("test-char-2", nil, "Test Char 2")
Assert("Default Location Char 2", "lalaland", CurrentEntity()["location"])
