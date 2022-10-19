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
