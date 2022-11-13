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
        TexApi.newEntity { type = "places", label = "place-" .. i, name = "Place " .. i }
        if true then
            local hist = EmptyHistoryItem()
            SetProtectedField(hist, "originator", "place-" .. i)
            SetYear(hist, -i)
            SetProtectedField(hist, "event", [[Birth of \reference{char-]] .. i .. [[} \birthof{char-]] .. i .. [[}]])
            ProcessEvent(hist)
        end
        AddRef("place-" .. i, PrimaryRefs)

        TexApi.newEntity { type = "species", label = "species-" .. i, name = "Species " .. i }
        SetAgeFactor(CurrentEntity(), i)
        AddRef("species-" .. i, PrimaryRefs)

        TexApi.newEntity { type = "organisations", label = "organisation-" .. i, name = "Organisation " .. i }
        AddRef("organisation-" .. i, PrimaryRefs)

        TexApi.newCharacter { label = "char-" .. i, name = "Character " .. i }
        SetSpecies(CurrentEntity(), "species-" .. i)
        SetLocation(CurrentEntity(), "place-" .. i)
        AddParent(CurrentEntity(), "organisation-" .. i)
        TexApi.setDescriptor { entity = CurrentEntity(),
            descriptor = "Best Friend",
            description = [[\nameref{mentioned-char-]] .. i .. [[}]] }
        AddRef("char-" .. i, PrimaryRefs)

        TexApi.newCharacter { label = "mentioned-char-" .. i, name = "Mentioned Character " .. i }
    end

    return TexApi.automatedChapters()
end
