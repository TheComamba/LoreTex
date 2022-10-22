local size = 1
function SetBenchmarkingSize(num)
    local numcast = tonumber(num)
    if numcast == nil then
        LogError("Called with " .. DebugPrint(num))
    else
        size = numcast
    end
end

function CreateBenchmarkingTest(sizeStr)
    local numcast = tonumber(sizeStr)
    if numcast == nil then
        LogError("Called with " .. DebugPrint(sizeStr))
    else
        size = numcast
    end
    for i = 1, size do
        NewEntity("place-" .. i, "places", nil, "Place " .. i)
        AddEvent(CurrentEntity(), -i, [[Birth of \reference{char-]] .. i .. [[} \birthof{char-]] .. i .. [[}]])
        AddRef("place-" .. i, PrimaryRefs)

        NewEntity("species-" .. i, "species", nil, "Species " .. i)
        SetDescriptor(CurrentEntity(), [[ageFactor]], i)
        AddRef("species-" .. i, PrimaryRefs)

        NewEntity("organisation-" .. i, "organisations", nil, "Organisation " .. i)
        AddRef("organisation-" .. i, PrimaryRefs)

        NewCharacter("char-" .. i, nil, "Character " .. i)
        SetDescriptor(CurrentEntity(), "species", "species-" .. i)
        SetDescriptor(CurrentEntity(), "location", "place-" .. i)
        AddParent(CurrentEntity(), "organisation-" .. i)
        SetDescriptor(CurrentEntity(), "Best Friend", [[\nameref{mentioned-char-]] .. i .. [[}]])
        AddRef("char-" .. i, PrimaryRefs)

        NewCharacter("mentioned-char-" .. i, nil, "Mentioned Character " .. i)
    end

    return AutomatedChapters()
end
