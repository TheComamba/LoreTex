TexApi.newEntity { type = "places", label = "test-place-1", name = "Test Place 1" }
Assert("Default Location Place 1", nil, GetProtectedField(CurrentEntity, "location"))
TexApi.newCharacter { label = "test-char-1", name = "Test Char 1" }
Assert("Default Location Char 1", nil, GetProtectedField(CurrentEntity, "location"))

PushScopedVariables()
SetScopedVariable("DefaultLocation", "lalaland")
TexApi.newEntity { type = "places", label = "test-place-2", name = "Test Place 2" }
Assert("Default Location Place 2", "lalaland", GetProtectedField(CurrentEntity, "location"))
TexApi.newCharacter { label = "test-char-2", name = "Test Char 2" }
Assert("Default Location Char 2", "lalaland", GetProtectedField(CurrentEntity, "location"))
PopScopedVariables()

TexApi.newEntity { type = "places", label = "test-place-3", name = "Test Place 3" }
Assert("Default Location Place 3", nil, GetProtectedField(CurrentEntity, "location"))
TexApi.newCharacter { label = "test-char-3", name = "Test Char 3" }
Assert("Default Location Char 3", nil, GetProtectedField(CurrentEntity, "location"))
