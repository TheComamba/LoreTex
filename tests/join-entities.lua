local first = { type = "place" }
SetProtectedField(first, "labels", { "first" })
local second = { type = "place", name = "Niceplace" }
SetProtectedField(second, "labels", { "second" })
local third = { neighbour = "Otherplace" }
SetProtectedField(third, "labels", { "third" })
local listOfSomeEntities = { first, second, third }
JoinEntities { main = first, aliases = { second, third } }

local expectedEntity = { type = "place", name = "Niceplace", neighbour = "Otherplace" }
SetProtectedField(expectedEntity, "labels", { "first", "second", "third" })
local expectedList = { expectedEntity, expectedEntity, expectedEntity }

Assert("Joining 3 entities", expectedList, listOfSomeEntities)
