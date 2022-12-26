local function setDescriptorAsKeyValPair(arg)
    if type(arg.description) == "string" and IsEmpty(arg.subdescriptor) then
        arg.subdescriptor = GetProtectedDescriptor("content")
    end
    if IsEmpty(arg.subdescriptor) then
        arg.entity[arg.descriptor] = arg.description
    else
        if arg.entity[arg.descriptor] == nil then
            arg.entity[arg.descriptor] = {}
        end
        arg.entity[arg.descriptor][arg.subdescriptor] = arg.description
    end
end

function SetDescriptor(arg)
    if not IsArgOk("SetDescriptor", arg, { "entity", "descriptor", "description" }, { "subdescriptor" }) then
        return
    end

    Replace([[\reference]], [[\nameref]], arg.description)
    if not IsEmpty(ScanForCmd(arg.description, "label")) then
        arg.description = ContentToEntity { name = arg.descriptor, content = arg.description }
        MakePartOf { subEntity = arg.description, mainEntity = arg.entity }
    elseif not IsEmpty(ScanForCmd(arg.description, "subparagraph")) then
        arg.description = ContentToMap(arg.description)
    else
        AddMentions(arg.entity, arg.description)
    end
    setDescriptorAsKeyValPair(arg)
end

TexApi.setDescriptor = function(arg)
    arg.entity = CurrentEntity
    SetDescriptor(arg)
end
