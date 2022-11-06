local testList = {}
Append(testList, "aaa")
Append(testList, "bbb")
Append(testList, 23)
Append(testList, 123)
Append(testList, "aaa 9")
Append(testList, "aaa 80")
Append(testList, "aaa 9 bbb")
Append(testList, "aaa 9 aaa")

local expected = {}
Append(expected, 23)
Append(expected, 123)
Append(expected, "aaa")
Append(expected, "aaa 9")
Append(expected, "aaa 9 aaa")
Append(expected, "aaa 9 bbb")
Append(expected, "aaa 80")
Append(expected, "bbb")

table.sort(testList, CompareStrings)

Assert("CompareStrings", expected, testList)