local function levelToCaptionstyle(level)
    if level == 1 then
        return "paragraph"
    elseif level == 2 then
        return "subparagraph"
    else
        return [[item \textbf]]
    end
end

local function appendTableDescription(out, description, level)
    local stringContent = GetProtectedStringField(description, "content")
    if stringContent ~= "" then
        Append(out, stringContent)
    end
    if IsMap(description) then
        Append(out, DescriptorsString(description, level + 1))
    elseif IsList(description) then
        Append(out, ListAll(description))
    end
end

local function appendDescriptorString(out, entity, descriptor, level)
    local captionstyle = levelToCaptionstyle(level)
    Append(out, TexCmd(captionstyle, CapFirst(descriptor)))
    local description = entity[descriptor]
    if type(description) == "string" then
        if not IsEmpty(description) then
            Append(out, description)
        end
    else
        appendTableDescription(out, description, level)
    end
end

function DescriptorsString(entity, level)
    if level == nil then
        level = 1
    elseif level > 10 then
        LogError { "Reached mildly unhealthy level of recursion for entity:", DebugPrint(entity) }
        return {}
    end
    local descriptorsList = {}
    for descriptor, description in pairs(entity) do
        if not IsProtectedDescriptor(descriptor) then
            descriptorsList[#descriptorsList + 1] = descriptor
        end
    end
    if #descriptorsList == 0 then
        return {}
    end
    Sort(descriptorsList, "compareAlphanumerical")

    local out = {}
    if level > 2 then
        Append(out, TexCmd("begin", "itemize"))
    end
    for key, descriptor in pairs(descriptorsList) do
        appendDescriptorString(out, entity, descriptor, level)
    end
    if level > 2 then
        Append(out, TexCmd("end", "itemize"))
    end
    return out
end
