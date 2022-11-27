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

local function mergePartsWithoutLabels(splitContent)
    local out = { splitContent[1] }
    for i = 2, #splitContent do
        local part = splitContent[i]
        local labels = ScanStringForCmd(part, "label")
        if #labels == 0 then
            out[#out] = out[#out] .. part
        else
            Append(out, part)
        end
    end
    return out
end

local function contentToEntityRaw(arg)
    if not IsArgOk("contentToEntityRaw", arg, { "mainEntity", "name", }, { "content" }) then
        return {}
    end

    local labels = ScanStringForCmd(arg.content, "label")
    local newEntity = {}
    if #labels > 0 then
        newEntity = GetMutableEntityFromAll(labels[1])
        for i = 2, #labels do
            LogError("Label \"" .. labels[i] .. "\" will be ignored.")
        end
    end
    SetProtectedField(newEntity, "name", arg.name)
    SetProtectedField(newEntity, "content", arg.content)
    AddMentions(newEntity, arg.content)
    MakePartOf { subEntity = newEntity, mainEntity = arg.mainEntity }
    return newEntity
end

function LabeledContentToEntity(arg)
    if not IsArgOk("LabeledContentToEntity", arg, { "mainEntity", "name", "content" }) then
        return ""
    end
    local contentSplit = splitContentAtSubparagraph(arg.content)
    contentSplit = mergePartsWithoutLabels(contentSplit)
    local newEntity = contentToEntityRaw { mainEntity = arg.mainEntity,
        name = arg.name,
        content = contentSplit[1] }
    for i = 2, #contentSplit do
        local part = contentSplit[i]
        local name = ScanStringForCmd(part, "subparagraph")[1]
        contentToEntityRaw { mainEntity = newEntity, name = name, content = part }
    end
    return newEntity
end
