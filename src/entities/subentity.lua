local generatedLabelFlag = [[_]]
local labelCounter = 0

StateResetters[#StateResetters + 1] = function()
    labelCounter = 0
end

function NewUniqueEntityLabel(name)
    labelCounter = labelCounter + 1
    return generatedLabelFlag .. LabelFromName(name) .. "-" .. labelCounter
end

function IsLabelGenerated(label)
    return label:find(generatedLabelFlag, 1, true) == 1
end

local function extractLabel(arg)
    local labels = ScanStringForCmd(arg.content, "label")
    for i = 2, #labels do
        LogError("Additional label \"" .. labels[i] .. "\" will be ignored.")
    end
    if #labels > 0 then
        return labels[1]
    else
        return NewUniqueEntityLabel(arg.name)
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
    return newEntity
end

local function splitContentAt(content, level)
    local contentSplit = {}
    local lastpos = 0
    while lastpos >= 0 do
        local nextpos = string.find(content, [[\]] .. level, lastpos + 1)
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

local function addMapEntry(map, content, name, level)
    local posSubpara = string.find(content, level)
    local earliestActualContent = posSubpara + string.len(level) + string.len(name)
    local beginActualContent = string.find(content, [[}]], earliestActualContent) + 1
    local actualContent = string.sub(content, beginActualContent)
    if string.find(actualContent, "label") ~= nil then
        local newEntity = ContentToEntity { name = name, content = actualContent }
        map[name] = newEntity
    else
        map[name] = actualContent
    end
end

local function listToMap(list, level)
    local map = {}
    if not IsEmpty(list[1]) then
        map[GetProtectedDescriptor("content")] = list[1]
    end
    for i = 2, #list do
        local content = list[i]
        local name = ScanForCmd(content, level)[1]
        if IsEmpty(name) then
            LogError("Description contains empty " .. level)
            return map
        elseif map[name] ~= nil then
            LogError(level .. " \"" .. name .. "\" is defined more than once!")
            return map
        end
        addMapEntry(map, content, name, level)
    end
    return map
end

function ContentToMap(content)
    local level = "paragraph"
    if string.find(content, [[\paragraph]]) == nil then
        level = "subparagraph"
    end
    local contentSplit = splitContentAt(content, level)
    return listToMap(contentSplit, level)
end

function IsMapString(content)
    if type(content) ~= "string" then
        return false
    else
        return string.find(content, [[\paragraph]]) ~= nil or string.find(content, [[\subparagraph]]) ~= nil
    end
end

function IsSubEntity(entity)
    return GetProtectedNullableField(entity, "partOf") ~= nil
end