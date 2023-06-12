local function newMountain(depth)
    TexApi.newEntity { label = "mountain-1", name = "mountain-1", type = "other" }
    if depth == 2 then
        TexApi.setDescriptor { descriptor = "mountain-2", description = [[\label{mountain-2}]] }
    elseif depth == 3 then
        TexApi.setDescriptor { descriptor = "mountain-2",
            description = [[\label{mountain-2}\subparagraph{mountain-3}\label{mountain-3}]] }
    end
end

local function generateHeightString(height)
    local out = {}
    Append(out, tostring(height))
    Append(out, "m (")
    if height == 0.5 then
        Append(out, "2.5")
    elseif height == 5 then
        Append(out, "8.0")
    elseif height == 50 then
        Append(out, "25")
    elseif height == 500 then
        Append(out, "80")
    elseif height == 5000 then
        Append(out, "250")
    end
    Append(out, "km ")
    Append(out, Tr("visual-range-to-horizon"))
    Append(out, ").")
    return table.concat(out)
end

local function generateExpected(depth, height)
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    for i = 1, depth do
        Append(out, [[\item \nameref{mountain-]] .. i .. [[}]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{mountain-1}]])
    Append(out, [[\label{mountain-1}]])
    Append(out, [[\paragraph{]] .. CapFirst(Tr("height")) .. [[}]])
    Append(out, generateHeightString(height))
    if depth >= 2 then
        Append(out, [[\paragraph{Mountain-2}]])
        Append(out, [[\label{mountain-2}]])
    end
    if depth >= 3 then
        Append(out, [[\subparagraph{Mountain-3}]])
        Append(out, [[\label{mountain-3}]])
    end
    return out
end

for depth = 1, 3 do
    for key, height in pairs({ 0.5, 5, 50, 500, 5000 }) do
        newMountain(depth)
        TexApi.setHeight(height)
        TexApi.makeAllEntitiesPrimary()
        local expexted = generateExpected(depth, height)
        AssertAutomatedChapters("setHeight depth " .. depth, expexted)
    end
end
