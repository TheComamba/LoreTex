local function entitySetup()
    TexApi.newEntity { category = "NPCs", label = "normal", name = "Normal" }
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }
    TexApi.addHistory { year = -10, event = [[Normal event]] }
    TexApi.addHistory { year = -9, event = [[Concerns \reference{secret}]] }
    TexApi.addHistory { year = -8, event = [[Concerns \reference{revealed}]] }
    TexApi.addSecretHistory { year = -5, event = [[Secret event]] }

    TexApi.newEntity { category = "NPCs", label = "secret", name = "Secret" }
    TexApi.setSecret()
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }
    TexApi.addHistory { year = -7, event = [[Concerns \reference{normal}]] }

    TexApi.newEntity { category = "NPCs", label = "revealed", name = "Revealed" }
    TexApi.setSecret()
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }
    TexApi.addHistory { year = -6, event = [[Concerns \reference{normal}]] }

    TexApi.newEntity { category = "NPCs", label = "unborn", name = "Unborn" }
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }
    TexApi.addHistory { year = 10, event = [[Created.\birthof{unborn}]] }

    TexApi.newEntity { category = "NPCs", label = "at_secret_location", name = "At secret Location" }
    TexApi.setLocation("eldorado")
    TexApi.addParent { parentLabel = "normal-orga" }
    TexApi.addParent { parentLabel = "secret-orga" }
    TexApi.addParent { parentLabel = "revealed-orga" }
    TexApi.addParent { parentLabel = "unborn-orga" }

    TexApi.newEntity { category = "places", label = "eldorado", name = "Eldorado" }
    TexApi.setSecret()

    TexApi.newEntity { category = "organisations", label = "normal-orga", name = "Normal Organisation" }

    TexApi.newEntity { category = "organisations", label = "secret-orga", name = "Secret Organisation" }
    TexApi.setSecret()

    TexApi.newEntity { category = "organisations", label = "revealed-orga", name = "Revealed Organisation" }
    TexApi.setSecret()

    TexApi.newEntity { category = "organisations", label = "unborn-orga", name = "Unborn Organisation" }
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
end

local function NPCsParagraph(isShowSecrets, isShowFuture)
    local out = {}
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ NPCs}]])
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
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("affiliations")) .. [[}]])
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
    Append(out, [[\chapter{NPCs}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ NPCs}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{at_secret_location}]])
    Append(out, [[\item \nameref{normal}]])
    Append(out, [[\item \nameref{revealed}]])
    if isShowFuture then
        Append(out, [[\item \nameref{unborn}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])

    Append(out, [[\subsection{Normal}]])
    Append(out, [[\label{normal}]])
    Append(out, affiliationParagraph(isShowSecrets, isShowFuture))
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
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

    Append(out, [[\subsection[Revealed]{Revealed (]] .. CapFirst(Tr("secret")) .. [[)}]])
    Append(out, [[\label{revealed}]])
    Append(out, affiliationParagraph(isShowSecrets, isShowFuture))
    Append(out, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out,
        [[\item -8 (]] ..
        Tr("x_years_ago", { 8 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{revealed}]])
    Append(out,
        [[\item -6 (]] ..
        Tr("x_years_ago", { 6 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{normal}]])
    Append(out, [[\end{itemize}]])

    if isShowFuture then
        Append(out, [[\subsection{Unborn}]])
        Append(out, [[\label{unborn}]])
        Append(out, affiliationParagraph(isShowSecrets, isShowFuture))
        Append(out, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item 10 (]] .. Tr("in_x_years", { 10 }) .. [[):\\ Created.\birthof{unborn}]])
        Append(out, [[\end{itemize}]])
    end

    if isShowSecrets then
        Append(out, [[\section{]] .. CapFirst(Tr("located_in")) .. [[ Eldorado}]])
    else
        Append(out, [[\section{]] .. CapFirst(Tr("at_secret_locations")) .. [[}]])
    end
    Append(out, [[\subsection{At secret Location}]])
    Append(out, [[\label{at_secret_location}]])
    Append(out, affiliationParagraph(isShowSecrets, isShowFuture))
    return out
end

local function otherChapter(isShowSecrets, isShowFuture)
    local out = {}
    Append(out, [[\chapter{Organisations}]])
    Append(out, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Organisations}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item \nameref{normal-orga}]])
    Append(out, [[\item \nameref{revealed-orga}]])
    if isShowFuture then
        Append(out, [[\item \nameref{unborn-orga}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
    Append(out, [[\subsection{Normal Organisation}]])
    Append(out, [[\label{normal-orga}]])
    Append(out, NPCsParagraph(isShowSecrets, isShowFuture))
    Append(out, [[\subsection[Revealed Organisation]{Revealed Organisation (]] .. CapFirst(Tr("secret")) .. [[)}]])
    Append(out, [[\label{revealed-orga}]])
    Append(out, NPCsParagraph(isShowSecrets, isShowFuture))
    if isShowFuture then
        Append(out, [[\subsection{Unborn Organisation}]])
        Append(out, [[\label{unborn-orga}]])
        Append(out, NPCsParagraph(isShowSecrets, isShowFuture))
        Append(out, [[\subsubsection{]] .. CapFirst(Tr("history")) .. [[}]])
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
local function setup1()
    refSetup()
    TexApi.showSecrets(false)
    TexApi.showFuture(false)
end
expected = generateExpected(false, false)
AssertAutomatedChapters("entity-visibility-no-secrets-no-future", expected, setup1)

entitySetup()
local function setup2()
    refSetup()
    TexApi.showSecrets(true)
    TexApi.showFuture(false)
end
expected = generateExpected(true, false)
AssertAutomatedChapters("entity-visibility-with-secrets-no-future", expected, setup2)

entitySetup()
local function setup3()
    refSetup()
    TexApi.showSecrets(false)
    TexApi.showFuture(true)
end
expected = generateExpected(false, true)
AssertAutomatedChapters("entity-visibility-no-secrets-with-future", expected, setup3)

entitySetup()
local function setup4()
    refSetup()
    TexApi.showSecrets(true)
    TexApi.showFuture(true)
end
expected = generateExpected(true, true)
AssertAutomatedChapters("entity-visibility-with-secrets-with-future", expected, setup4)
