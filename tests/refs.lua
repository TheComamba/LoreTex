local str = [[A \nameref {pair} of \ref {trousers} is \not {} a \pear     {you guys}.]]
local args = {
    { str, "nameref", { "pair" } },
    { str, "ref", { "trousers" } },
    { str, "not", { "" } },
    { str, "pear", { "you guys" } },
    { [[Several \ref{1} \ref {2} \ref  {3}]], "ref", { "1", "2", "3" } },
    { [[False alarm \reference {Castingshow}]], "ref", {} }
}
for key, arg in pairs(args) do
    Assert("ScanForCmd", arg[3], ScanForCmd(arg[1], arg[2]))
end
