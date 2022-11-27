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
    for i = size, 1, -1 do
        TexApi.newEntity { type = "places", label = "place-" .. i, name = "Place " .. i }
        TexApi.addHistory { year = -i, event = [[Birth of \reference{char-]] .. i .. [[-1} \birthof{char-]] .. i .. [[-1}]] }
        TexApi.makeEntityPrimary("place-" .. i)

        TexApi.newEntity { type = "species", label = "species-" .. i, name = "Species " .. i }
        TexApi.setAgeFactor(i)
        TexApi.makeEntityPrimary("species-" .. i)

        TexApi.newEntity { type = "organisations", label = "organisation-" .. i, name = "Organisation " .. i }
        TexApi.makeEntityPrimary("organisation-" .. i)
        if i > 1 then
            TexApi.setLocation("place-" .. (i - 1))
        end

        for j = 10, 1, -1 do
            local label = "char-" .. i .. "-" .. j
            TexApi.newCharacter { label = label, name = label }
            TexApi.setSpecies("species-" .. i)
            TexApi.setLocation("place-" .. i)
            TexApi.addParent { parentLabel = "organisation-" .. i }
            TexApi.setDescriptor { descriptor = "Best Friend", description = [[\nameref{mentioned-char-]] .. i .. [[}]] }
            TexApi.makeEntityPrimary(label)
        end

        TexApi.newCharacter { label = "mentioned-char-" .. i, name = "Mentioned Character " .. i }
    end

    local out = TexApi.automatedChapters()
    StopBenchmarking("All")
    return out
end
