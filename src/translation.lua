Dictionaries = {}
IsDictionaryRandomised = false

local currentDictionary = {}

local function selectLanguage(language)
    dofile(RelativePath .. "/../translation/" .. language .. ".lua")
    currentDictionary = Dictionaries[language:lower()]
    IsDictionaryRandomised = false
end

TexApi.selectLanguage = selectLanguage

function Tr(keyword, additionalArguments)
    local translation = currentDictionary[keyword]
    if translation == nil then
        LogError("Could not find translation for keyword \"" .. keyword .. "\".")
        translation = keyword:upper()
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
    for i = 1, length do
        Append(out, string.char(math.random(97, 97 + 25)))
    end
    return table.concat(out)
end

function RandomiseDictionary()
    --Before you ask: This is purely for testing.
    for key, _ in pairs(currentDictionary) do
        currentDictionary[key] = currentDictionary[key]:lower() .. "_" .. randomWord(5)
    end
    IsDictionaryRandomised = true
end
