local function extractLabel(arg)
    local labels = ScanStringForCmd(arg.content, "label")
    for i = 2, #labels do
        LogError("Label \"" .. labels[i] .. "\" will be ignored.")
    end
    if #labels > 0 then
        return labels[1]
    else
        return LabelFromName(arg.name)
    end
end

function ContentToEntity(arg)
    if not IsArgOk("ContentToEntity", arg, { "name", "content" }) then
        return {}
    end
    local map = ContentToMap(arg.content)
    local contentBeforeSubpara = GetProtectedStringField(map, "content")
    local label = extractLabel { content = contentBeforeSubpara, name = arg.name }
    local newEntity = GetMutableEntityFromAll(label)
    SetProtectedField(newEntity, "name", arg.name)
    for key, val in pairs(map) do
        newEntity[key] = val
        if IsEntity(val) then
            MakePartOf { subEntity = val, mainEntity = newEntity }
        end
    end
    AddMentions(newEntity, arg.content)
    return newEntity
end

local function splitContentAtSubparagraph(content)
    local contentSplit = {}
    local lastpos = 0
    while lastpos >= 0 do
        local nextpos = string.find(content, [[\subparagraph]], lastpos + 1)
        local part = ""
        if nextpos == nil then
            part = string.sub(content, lastpos)
            nextpos = -1
        else
            part = string.sub(content, lastpos, nextpos - 1)
        end
        Append(contentSplit, part)
        lastpos = nextpos
    end
    return contentSplit
end

local function addMapEntry(map, content, name)
    local posSubpara = string.find(content, "subparagraph")
    local earliestActualContent = posSubpara + string.len("subparagraph") + string.len(name)
    local beginActualContent = string.find(content, [[}]], earliestActualContent) + 1
    local actualContent = string.sub(content, beginActualContent)
    if string.find(actualContent, "label") ~= nil then
        local newEntity = ContentToEntity { name = name, content = actualContent }
        map[name] = newEntity
    else
        map[name] = actualContent
    end
end

local function listToMap(list)
    local map = {}
    if not IsEmpty(list[1]) then
        map[GetProtectedDescriptor("content")] = list[1]
    end
    for i = 2, #list do
        local content = list[i]
        local name = ScanForCmd(content, "subparagraph")[1]
        if IsEmpty(name) then
            LogError("Description contains empty subparagraph!")
            return map
        elseif map[name] ~= nil then
            LogError("Subparagraph \"" .. name .. "\" is defined more than once!")
            return map
        end
        addMapEntry(map, content, name)
    end
    return map
end

function ContentToMap(content)
    local contentSplit = splitContentAtSubparagraph(content)
    return listToMap(contentSplit)
end
