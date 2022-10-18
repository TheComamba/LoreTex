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
        NewEntity("place-" .. i, "place", nil, "Place " .. i)
        AddEvent(CurrentEntity(), -i, [[Birth of \reference{char-]] .. i .. [[} \birthof{char-]] .. i .. [[}]])

        NewEntity("species-" .. i, "species", nil, "Species " .. i)
        SetDescriptor(CurrentEntity(), [[ageFactor]], i)

        NewCharacter("char-" .. i, nil, "Character " .. i)
        SetDescriptor(CurrentEntity(), "species", "species-" .. i)
        SetDescriptor(CurrentEntity(), "location", "place-" .. i)
    end

    AddAllEntitiesToPrimaryRefs()
    return AutomatedChapters()
end
