local str = [[A \myref {pair} of \ref {trousers} is \not {} a \ref{\pear     {you guys}}.]]
local args = {
    {str, "myref", {"pair"}},
    {str, "ref", {"trousers", [[\pear{}]]}},
    {str, "not", {""}},
    {str, "pear", {"you guys"}}
}
for key, arg in pairs(args) do
    Assert("ScanForCmd", arg[3], ScanForCmd(arg[1], arg[2]))
end