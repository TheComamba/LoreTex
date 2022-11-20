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
    StartBenchmarking("All")
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
        TexApi.makeEntityPrimary("place-" .. i)

        TexApi.newEntity { type = "species", label = "species-" .. i, name = "Species " .. i }
        TexApi.setAgeFactor(i)
        TexApi.makeEntityPrimary("species-" .. i)

        TexApi.newEntity { type = "organisations", label = "organisation-" .. i, name = "Organisation " .. i }
        TexApi.makeEntityPrimary("organisation-" .. i)

        TexApi.newCharacter { label = "char-" .. i, name = "Character " .. i }
        TexApi.setSpecies("species-" .. i)
        TexApi.setLocation("place-" .. i)
        TexApi.addParent { parentLabel = "organisation-" .. i }
        TexApi.setDescriptor { descriptor = "Best Friend", description = [[\nameref{mentioned-char-]] .. i .. [[}]] }
        TexApi.makeEntityPrimary("char-" .. i)

        TexApi.newCharacter { label = "mentioned-char-" .. i, name = "Mentioned Character " .. i }
    end

    local out = TexApi.automatedChapters()
    StopBenchmarking("All")
    return out
end
