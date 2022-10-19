Dictionary = {}

function SelectLanguage(language)
    dofile(RelativePath .. "/translation/" .. language .. ".lua")
end

function Tr(keyword)
    local translation = Dictionary[keyword]
    if translation == nil then
        LogError("Could not find translation for keyword " .. DebugPrint(keyword))
        translation = ""
    end
    return translation
end
