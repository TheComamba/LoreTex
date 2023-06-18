local function setDescriptorAsKeyValPair(arg)
    local currentDescription = arg.entity[arg.descriptor]
    if type(arg.description) == "string" and IsEntity(currentDescription) then
        currentDescription[GetProtectedDescriptor("content")] = arg.description
    elseif type(currentDescription) == "string" and IsEntity(arg.description) then
        arg.description[GetProtectedDescriptor("content")] = currentDescription
        arg.entity[arg.descriptor] = arg.description
    else
        arg.entity[arg.descriptor] = arg.description
    end
end

function SetDescriptor(arg)
    if not IsArgOk("SetDescriptor", arg, { "entity", "descriptor", "description" }, { "subdescriptor",
            "suppressDerivedDescriptors" }) then
        return
    end

    Replace([[\reference]], [[\nameref]], arg.description)
    if not arg.suppressDerivedDescriptors then
        AddMentions(arg.entity, arg.description)
    end
    if not IsEmpty(ScanForCmd(arg.description, "label")) then
        arg.description = ContentToEntity { name = arg.descriptor, content = arg.description }
        MakePartOf { subEntity = arg.description, mainEntity = arg.entity }
    elseif not IsEmpty(ScanForCmd(arg.description, "subparagraph")) then
        arg.description = ContentToMap(arg.description)
    elseif not IsEmpty(arg.subdescriptor) then
        local content = arg.description
        local currentDescription = arg.entity[arg.descriptor]
        if IsEmpty(currentDescription) or not IsEntity(currentDescription) then
            local entityLabel = GetProtectedStringField(arg.entity, "label")
            local subLabel = NewUniqueLabel(entityLabel .. "-" .. arg.descriptor)
            local subEntity = GetMutableEntityFromAll(subLabel)
            SetProtectedField(subEntity, "name", arg.descriptor)
            arg.description = subEntity
        else
            arg.description = currentDescription
        end
        SetDescriptor { entity = arg.description, descriptor = arg.subdescriptor, description = content }
        MakePartOf { subEntity = arg.description, mainEntity = arg.entity }
        arg.subdescriptor = nil
    end
    setDescriptorAsKeyValPair(arg)
end

TexApi.setDescriptor = function(arg)
    arg.entity = CurrentEntity
    SetDescriptor(arg)
end
