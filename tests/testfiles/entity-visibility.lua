local function entitySetup()
    TexApi.addType { metatype = "other", type = "organisations" }
    TexApi.addTranslation { language = "english", key = "organisations", translation = "organisations" }

    TexApi.newEntity { type = "NPCs", label = "normal", name = "Normal" }
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }
    TexApi.addHistory { year = -10, event = [[Normal event]] }
    TexApi.addHistory { year = -9, event = [[Concerns \reference{secret}]] }
    TexApi.addHistory { year = -8, event = [[Concerns \reference{revealed}]] }
    TexApi.addSecretHistory { year = -5, event = [[Secret event]] }
    
    TexApi.newEntity { type = "NPCs", label = "secret", name = "Secret" }
    TexApi.setSecret()
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }
    TexApi.addHistory { year = -7, event = [[Concerns \reference{normal}]] }
    
    TexApi.newEntity { type = "NPCs", label = "revealed", name = "Revealed" }
    TexApi.setSecret()
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }
    TexApi.addHistory { year = -6, event = [[Concerns \reference{normal}]] }
    
    TexApi.newEntity { type = "NPCs", label = "unborn", name = "Unborn" }
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }
    TexApi.addHistory { year = 10, event = [[Created.\birthof{unborn}]] }
    
    TexApi.newEntity { type = "NPCs", label = "at_secret_location", name = "At secret Location" }
    TexApi.setLocation("eldorado")
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }
    
    TexApi.newEntity { type = "places", label = "eldorado", name = "Eldorado" }
    TexApi.setSecret()
    
    TexApi.newEntity { type = "organisations", label = "normal-orga", name = "Normal Organisation" }
    
    TexApi.newEntity { type = "organisations", label = "secret-orga", name = "Secret Organisation" }
    TexApi.setSecret()
    
    TexApi.newEntity { type = "organisations", label = "revealed-orga", name = "Revealed Organisation" }
    TexApi.setSecret()
    
    TexApi.newEntity { type = "organisations", label = "unborn-orga", name = "Unborn Organisation" }
    TexApi.born { year = 10, event = [[Founded.\birthof{unborn-orga}]] }
end

local function refSetup()
    TexApi.makeEntityPrimary("normal")
    TexApi.makeEntityPrimary("unborn")
    TexApi.makeEntityPrimary("at_secret_location")
    TexApi.makeEntityPrimary("normal-orga")
    TexApi.makeEntityPrimary("unborn-orga")
    TexApi.reveal("revealed")
    TexApi.reveal("revealed-orga")

    TexApi.setCurrentYear(0)
    TexApi.addType { metatype = "characters", type = "NPCs" }
end

local function NPCsParagraph(isShowSecrets, isShowFuture)
    local out = {}
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("NPCs") .. [[}]])
    Append(out, [[\begin{itemize}]])
    if isShowSecrets then
        Append(out, [[\item \nameref{at_secret_location} (]] .. Tr("located_in") .. [[ \nameref{eldorado})]])
    else
        Append(out, [[\item \nameref{at_secret_location} (]] .. Tr("at_secret_location") .. [[)]])
    end
    Append(out, [[\item \nameref{normal}]])
    Append(out, [[\item \nameref{revealed} (]] .. Tr("secret") .. [[)]])
    if isShowSecrets then
        Append(out, [[\item \nameref{secret} (]] .. Tr("secret") .. [[)]])
    end
    if isShowFuture then
        Append(out, [[\item \nameref{unborn}]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function affiliationParagraph(isShowSecrets, isShowFuture)
    local out = {}
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{normal-orga}.]])
    Append(out,
        [[\item (]] ..
        CapFirst(Tr("secret")) .. [[) ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{revealed-orga}.]])
    if isShowSecrets then
        Append(out,
            [[\item (]] ..
            CapFirst(Tr("secret")) ..
            [[) ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{secret-orga}.]])
    end
    if isShowFuture then
        Append(out, [[\item ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{unborn-orga}.]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function charactersChapter(isShowSecrets, isShowFuture)
    local out = {}
    Append(out, [[\chapter{Characters}]])
    Append(out, [[\section{NPCs}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{at_secret_location}]])
    Append(out, [[\item \nameref{normal}]])
    Append(out, [[\item \nameref{revealed}]])
    if isShowFuture then
        Append(out, [[\item \nameref{unborn}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])

    Append(out, [[\subsubsection{Normal}]])
    Append(out, [[\label{normal}]])
    Append(out, affiliationParagraph(isShowSecrets, isShowFuture))
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item -10 (]] .. Tr("x_years_ago", { 10 }) .. [[):\\ Normal event]])
    if isShowSecrets then
        Append(out,
            [[\item -9 (]] ..
            Tr("x_years_ago", { 9 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{secret}]])
    end
    Append(out,
        [[\item -8 (]] ..
        Tr("x_years_ago", { 8 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{revealed}]])
    if isShowSecrets then
        Append(out,
            [[\item -7 (]] ..
            Tr("x_years_ago", { 7 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{normal}]])
    end
    Append(out,
        [[\item -6 (]] ..
        Tr("x_years_ago", { 6 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{normal}]])
    if isShowSecrets then
        Append(out,
            [[\item -5 (]] .. Tr("x_years_ago", { 5 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Secret event]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsubsection[Revealed]{Revealed (]] .. CapFirst(Tr("secret")) .. [[)}]])
    Append(out, [[\label{revealed}]])
    Append(out, affiliationParagraph(isShowSecrets, isShowFuture))
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out,
        [[\item -8 (]] ..
        Tr("x_years_ago", { 8 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{revealed}]])
    Append(out,
        [[\item -6 (]] ..
        Tr("x_years_ago", { 6 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{normal}]])
    Append(out, [[\end{itemize}]])

    if isShowFuture then
        Append(out, [[\subsubsection{Unborn}]])
        Append(out, [[\label{unborn}]])
        Append(out, affiliationParagraph(isShowSecrets, isShowFuture))
        Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item 10 (]] .. Tr("in_x_years", { 10 }) .. [[):\\ Created.\birthof{unborn}]])
        Append(out, [[\end{itemize}]])
    end

    if isShowSecrets then
        Append(out, [[\subsection{]] .. CapFirst(Tr("located_in")) .. [[ Eldorado}]])
    else
        Append(out, [[\subsection{]] .. CapFirst(Tr("at_secret_locations")) .. [[}]])
    end
    Append(out, [[\subsubsection{At secret Location}]])
    Append(out, [[\label{at_secret_location}]])
    Append(out, affiliationParagraph(isShowSecrets, isShowFuture))
    return out
end

local function otherChapter(isShowSecrets, isShowFuture)
    local out = {}
    Append(out, [[\chapter{Other}]])
    Append(out, [[\section{]] .. CapFirst(Tr("organisations")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("organisations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{normal-orga}]])
    Append(out, [[\item \nameref{revealed-orga}]])
    if isShowFuture then
        Append(out, [[\item \nameref{unborn-orga}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(out, [[\subsubsection{Normal Organisation}]])
    Append(out, [[\label{normal-orga}]])
    Append(out, NPCsParagraph(isShowSecrets, isShowFuture))
    Append(out, [[\subsubsection[Revealed Organisation]{Revealed Organisation (]] .. CapFirst(Tr("secret")) .. [[)}]])
    Append(out, [[\label{revealed-orga}]])
    Append(out, NPCsParagraph(isShowSecrets, isShowFuture))
    if isShowFuture then
        Append(out, [[\subsubsection{Unborn Organisation}]])
        Append(out, [[\label{unborn-orga}]])
        Append(out, NPCsParagraph(isShowSecrets, isShowFuture))
        Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item 10 (]] .. Tr("in_x_years", { 10 }) .. [[):\\ Founded.\birthof{unborn-orga}]])
        Append(out, [[\end{itemize}]])
    end
    return out
end

local function onlyMentionedChapter(isShowSecrets)
    local out = {}
    if isShowSecrets then
        Append(out, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])
        Append(out, [[\subparagraph{Eldorado}]])
        Append(out, [[\label{eldorado}]])
        Append(out, [[\hspace{1cm}]])
        Append(out, [[\subparagraph{Secret}]])
        Append(out, [[\label{secret}]])
        Append(out, [[\hspace{1cm}]])
        Append(out, [[\subparagraph{Secret Organisation}]])
        Append(out, [[\label{secret-orga}]])
        Append(out, [[\hspace{1cm}]])
    end
    return out
end

local function generateExpected(isShowSecrets, isShowFuture)
    local out = {}
    Append(out, charactersChapter(isShowSecrets, isShowFuture))
    Append(out, otherChapter(isShowSecrets, isShowFuture))
    Append(out, onlyMentionedChapter(isShowSecrets))
    return out
end

local out = {}
local expected = {}

entitySetup()
TexApi.showSecrets(false)
TexApi.showFuture(false)
expected = generateExpected(false, false)
AssertAutomatedChapters("entity-visibility-no-secrets-no-future", expected, refSetup)

entitySetup()
TexApi.showSecrets(true)
TexApi.showFuture(false)
expected = generateExpected(true, false)
AssertAutomatedChapters("entity-visibility-with-secrets-no-future", expected, refSetup)

entitySetup()
TexApi.showSecrets(false)
TexApi.showFuture(true)
expected = generateExpected(false, true)
AssertAutomatedChapters("entity-visibility-no-secrets-with-future", expected, refSetup)

entitySetup()
TexApi.showSecrets(true)
TexApi.showFuture(true)
expected = generateExpected(true, true)
AssertAutomatedChapters("entity-visibility-with-secrets-with-future", expected, refSetup)
