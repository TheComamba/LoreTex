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
        NewEntity("places", "place-" .. i, nil, "Place " .. i)
        if true then
            local hist = EmptyHistoryItem()
            SetProtectedField(hist, "originator", "place-" .. i)
            SetYear(hist, -i)
            SetProtectedField(hist, "event", [[Birth of \reference{char-]] .. i .. [[} \birthof{char-]] .. i .. [[}]])
            ProcessEvent(hist)
        end
        AddRef("place-" .. i, PrimaryRefs)

        NewEntity("species", "species-" .. i, nil, "Species " .. i)
        SetAgeFactor(CurrentEntity(), i)
        AddRef("species-" .. i, PrimaryRefs)

        NewEntity("organisations", "organisation-" .. i, nil, "Organisation " .. i)
        AddRef("organisation-" .. i, PrimaryRefs)

        NewCharacter("char-" .. i, nil, "Character " .. i)
        SetSpecies(CurrentEntity(), "species-" .. i)
        SetLocation(CurrentEntity(), "place-" .. i)
        AddParent(CurrentEntity(), "organisation-" .. i)
        SetDescriptor(CurrentEntity(), "Best Friend", [[\nameref{mentioned-char-]] .. i .. [[}]])
        AddRef("char-" .. i, PrimaryRefs)

        NewCharacter("mentioned-char-" .. i, nil, "Mentioned Character " .. i)
    end

    return AutomatedChapters()
end
