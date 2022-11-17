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
    TexApi.setCurrentYear(1400)
    for i = 1, size do
        TexApi.newEntity { type = "places", label = "place-" .. i, name = "Place " .. i }
        TexApi.addHistory { year = -i, event = [[Birth of \reference{char-]] .. i .. [[} \birthof{char-]] .. i .. [[}]] }
        AddRef("place-" .. i, PrimaryRefs)

        TexApi.newEntity { type = "species", label = "species-" .. i, name = "Species " .. i }
        TexApi.setAgeFactor(i)
        AddRef("species-" .. i, PrimaryRefs)

        TexApi.newEntity { type = "organisations", label = "organisation-" .. i, name = "Organisation " .. i }
        AddRef("organisation-" .. i, PrimaryRefs)

        TexApi.newCharacter { label = "char-" .. i, name = "Character " .. i }
        TexApi.setSpecies("species-" .. i)
        TexApi.setLocation("place-" .. i)
        TexApi.addParent { parentLabel = "organisation-" .. i }
        TexApi.setDescriptor { descriptor = "Best Friend", description = [[\nameref{mentioned-char-]] .. i .. [[}]] }
        AddRef("char-" .. i, PrimaryRefs)

        TexApi.newCharacter { label = "mentioned-char-" .. i, name = "Mentioned Character " .. i }
    end

    return TexApi.automatedChapters()
end
