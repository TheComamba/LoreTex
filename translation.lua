Dictionary = {}

function SelectLanguage(language)
    dofile(RelativePath .. "/translation/" .. language .. ".lua")
end

function Tr(keyword, additionalArguments)
    local translation = Dictionary[keyword]
    if translation == nil then
        LogError("Could not find translation for keyword " .. DebugPrint(keyword))
        translation = ""
    end
    if additionalArguments ~= nil then
        for i, arg in pairs(additionalArguments) do
            local argFlag = [[{]] .. i .. [[}]]
            translation = Replace(argFlag, tostring(arg), translation)
        end
    end
    return translation
end

function CapFirst(str)
    return (str:gsub("^%l", string.upper))
end

local function randomWord(length)
    local out = {}
    for i = 1,length do
        Append(out, string.char(math.random(97,97+25)))
    end
    return table.concat(out)
end

function RandomiseDictionary()
    --Before you ask: This is purely for testing.
    --Only one word appended at beginning such that every word starts lowercase, but sorting of keywords remains the same.
    local oneRandomWord = randomWord(5)
    for key, val in pairs(Dictionary) do
        Dictionary[key] = oneRandomWord .. "-".. Dictionary[key]
    end
end