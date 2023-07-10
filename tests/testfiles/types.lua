local function setup()
    TexApi.addType { metatype = "other", type = "hair-products" }
    TexApi.addType { metatype = "nonsense", type = "laces" }

    TexApi.addTranslation { language = "english", key = "hair-products", translation = "hair products" }
    TexApi.addTranslation { language = "english", key = "nonsense", translation = "nonsense" }
    TexApi.addTranslation { language = "english", key = "laces", translation = "laces" }

    TexApi.addTranslation { language = "german", key = "hair-products", translation = "Haarprodukte" }
    TexApi.addTranslation { language = "german", key = "nonsense", translation = "Unfug" }
    TexApi.addTranslation { language = "german", key = "laces", translation = [[Schnürsenkel]] }

    TexApi.newEntity { type = "hair-products", label = "cream", name = "Cream" }
    TexApi.newEntity { type = "laces", label = "red-laces", name = "Red laces" }
end

local function generateOther(language)
    local haiproducts = ""
    if language == "english" then
        haiproducts = "hair products"
    elseif language == "german" then
        haiproducts = "Haarprodukte"
    end

    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("other")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(haiproducts) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(haiproducts) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{cream}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(out, [[\subsubsection{Cream}]])
    Append(out, [[\label{cream}]])
    return out
end

local function generateNonsense(language)
    local nonsense = ""
    local laces = ""
    if language == "english" then
        nonsense = "nonsense"
        laces = "laces"
    elseif language == "german" then
        nonsense = "Unfug"
        laces = [[Schnürsenkel]]
    end

    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(nonsense) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(laces) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(laces) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{red-laces}]])
    Append(out, [[\end{itemize}]])
    Append(out, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(out, [[\subsubsection{Red laces}]])
    Append(out, [[\label{red-laces}]])
    return out
end

local function generateExpected(language)
    local out = {}
    if language == "english" then
        Append(out, generateNonsense(language))
        Append(out, generateOther(language))
    elseif language == "german" then
        Append(out, generateOther(language))
        Append(out, generateNonsense(language))
    else
        LogError("Generate expected called with unexpected language \"" .. language .. "\".")
    end
    return out
end

local expected = {}
setup()
TexApi.selectLanguage("english")
expected = generateExpected("english")
AssertAutomatedChapters("New type (english)", expected, TexApi.makeAllEntitiesPrimary)

setup()
TexApi.selectLanguage("german")
expected = generateExpected("german")
AssertAutomatedChapters("New type (german)", expected, TexApi.makeAllEntitiesPrimary)
