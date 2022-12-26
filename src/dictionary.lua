local interColumnSpacing = 0.022

local function columnWidth(colNum)
    if type(colNum) ~= "number" or colNum < 1 then
        LogError("Called with " .. DebugPrint(colNum))
        return 0.01
    end
    local width = 0.47
    width = width - interColumnSpacing * (colNum - 1)
    return width / colNum
end

local function columnWidthsString(colNum)
    local width = columnWidth(colNum)
    local out = {}
    for i = 1, colNum do
        Append(out, [[p{]] .. width .. [[\textwidth}]])
    end
    return out
end

local function firstTableLine(headers)
    local out = {}
    for key, head in pairs(headers) do
        Append(out, TexCmd("clmhead", head))
        if key < #headers then
            Append(out, [[&]])
        else
            Append(out, [[\\]])
        end
    end
    Append(out, [[\hline]]) --it is important to not add the {}
    return table.concat(out) --it is important to concat here
end

local function tableHead(headers)
    local out = {}
    Append(out, TexCmd("tablehead", firstTableLine(headers)))
    Append(out, TexCmd("begin", "center"))
    Append(out, TexCmd("begin", "supertabular"))
    Append(out, [[{]])
    Append(out, columnWidthsString(#headers))
    Append(out, [[}]])
    return out
end

local function tableEnd()
    local out = {}
    Append(out, TexCmd("end", "supertabular"))
    Append(out, TexCmd("end", "center"))
    return out
end

function PrintTable(tab)
    local out = {}
    Append(out, tableHead(tab[1]))
    for i = 2, #tab do
        for j = 1, #tab[i] do
            Append(out, tab[i][j])
            if j < #tab[i] then
                Append(out, [[&]])
            else
                Append(out, [[\\]])
            end
        end
    end
    Append(out, tableEnd())
    return out
end
