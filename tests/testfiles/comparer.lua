local expected = {}
Append(expected, 23)
Append(expected, "45")
Append(expected, 123)
Append(expected, "345")
Append(expected, "1zz22abc3")
Append(expected, "1zz22abc11")
Append(expected, [[\LoreTexSort{9} zzz]])
Append(expected, [[\LoreTexSort{88} aaa]])
Append(expected, [[\LoreTexSort{193}Function1 was called 193 times.]])
Append(expected, [[\LoreTexSort{1679}Function2 was called 1679 times.]])
Append(expected, "a1zz22abc3")
Append(expected, "a1zz22abc11")
Append(expected, "aaa")
Append(expected, "aaa9")
Append(expected, "aaa9aaa")
Append(expected, "aaa9bbb")
Append(expected, "aaa80")
Append(expected, "aaa91")
Append(expected, "aaaa")
Append(expected, "bbb")
Append(expected, "eFg")
Append(expected, "efGh")
Append(expected, "Ii")
Append(expected, "ii")

local received = {}
for i = #expected, 1, -1 do
    Append(received, expected[i])
end
Sort(received, "compareAlphanumerical")

Assert("CompareAlphanumerical", expected, received)
