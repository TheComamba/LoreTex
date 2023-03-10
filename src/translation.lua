Dictionaries = {}
IsDictionaryRandomised = false

local currentDictionary = {}

local function selectLanguage(language)
    if #currentDictionary == 0 then
        dofile(RelativePath .. "/../translation/" .. language .. ".lua")
    end
    currentDictionary = Dictionaries[language:lower()]
    IsDictionaryRandomised = false
end

TexApi.selectLanguage = selectLanguage

local function addTranslation(arg)
    if not IsArgOk("addTranslation", arg, { "language", "key", "translation" }, {}) then
        return
    end
    if Dictionaries[arg.language] == nil then
        Dictionaries[arg.language] = {}
    end
    Dictionaries[arg.language][arg.key] = arg.translation
end

TexApi.addTranslation = addTranslation

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
    for key, val in pairs(currentDictionary) do
        currentDictionary[key] = currentDictionary[key]:lower() .. "-" .. randomWord(5)
    end
    IsDictionaryRandomised = true
end
