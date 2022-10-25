NewEntity("items", "normal", nil, "Normal")
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "normal"
    SetYear(hist, -10)
    hist["event"] = [[Normal event]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "normal"
    SetYear(hist, -9)
    hist["event"] = [[Concerns \reference{secret}]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "normal"
    SetYear(hist, -8)
    hist["event"] = [[Concerns \reference{revealed}]]
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "normal"
    SetYear(hist, -5)
    hist["event"] = [[Secret event]]
    hist["isSecret"] = true
    ProcessEvent(hist)
end
AddRef("normal", PrimaryRefs)

NewEntity("items", "secret", nil, "Secret")
SetSecret(CurrentEntity())
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "secret"
    SetYear(hist, -7)
    hist["event"] = [[Concerns \reference{normal}]]
    ProcessEvent(hist)
end

NewEntity("items", "revealed", nil, "Revealed")
SetSecret(CurrentEntity())
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "revealed"
    SetYear(hist, -6)
    hist["event"] = [[Concerns \reference{normal}]]
    ProcessEvent(hist)
end
Reveal("revealed")

NewEntity("items", "unborn", nil, "Unborn")
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "unborn"
    SetYear(hist, 10)
    hist["event"] = [[Created.\birthof{unborn}]]
    ProcessEvent(hist)
end
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
AddRef("unborn", PrimaryRefs)

NewEntity("items", "at-secret-location", nil, "At secret Location")
SetLocation(CurrentEntity(), "eldorado")
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
AddRef("at-secret-location", PrimaryRefs)

NewEntity("places", "eldorado", nil, "Eldorado")
SetSecret(CurrentEntity())

NewEntity("organisations", "normal-orga", nil, "Normal Organisation")
AddRef("normal-orga", PrimaryRefs)

NewEntity("organisations", "secret-orga", nil, "Secret Organisation")
SetSecret(CurrentEntity())

NewEntity("organisations", "revealed-orga", nil, "Revealed Organisation")
SetSecret(CurrentEntity())
Reveal("revealed-orga")

NewEntity("organisations", "unborn-orga", nil, "Unborn Organisation")
if true then
    local hist = EmptyHistoryItem()
    hist["originator"] = "unborn-orga"
    SetYear(hist, 10)
    hist["event"] = [[Founded.\birthof{unborn-orga}]]
    ProcessEvent(hist)
end
AddRef("unborn-orga", PrimaryRefs)

local function itemsParagraph()
    local out = {}
    Append(out, [[\paragraph{]] .. CapFirst(Tr("items")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    if IsShowSecrets then
        Append(out, [[\item{} \nameref{at-secret-location} (]] .. Tr("in") .. [[ \nameref{eldorado})]])
    else
        Append(out, [[\item{} \nameref{at-secret-location} (]] .. Tr("at-secret-location") .. [[)]])
    end
    Append(out, [[\item{} \nameref{normal}]])
    Append(out, [[\item{} \nameref{revealed} (]] .. Tr("secret") .. [[)]])
    if IsShowSecrets then
        Append(out, [[\item{} \nameref{secret} (]] .. Tr("secret") .. [[)]])
    end
    if IsShowFuture then
        Append(out, [[\item{} \nameref{unborn}]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function affiliationParagraph()
    local out = {}
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{normal-orga}.]])
    Append(out,
        [[\item{} (]] ..
        CapFirst(Tr("secret")) .. [[) ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{revealed-orga}.]])
    if IsShowSecrets then
        Append(out,
            [[\item{} (]] ..
            CapFirst(Tr("secret")) ..
            [[) ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{secret-orga}.]])
    end
    if IsShowFuture then
        Append(out, [[\item{} ]] .. CapFirst(Tr("member")) .. [[ ]] .. Tr("of") .. [[ \nameref{unborn-orga}.]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function generateExpected()
    local out = {}
    Append(out, [[\chapter{]] .. CapFirst(Tr("associations")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("organisations")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("organisations")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{normal-orga}]])
    Append(out, [[\item{} \nameref{revealed-orga}]])
    if IsShowFuture then
        Append(out, [[\item{} \nameref{unborn-orga}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])
    Append(out, [[\subsubsection{Normal Organisation}]])
    Append(out, [[\label{normal-orga}]])
    Append(out, itemsParagraph())
    Append(out, [[\subsubsection[Revealed Organisation]{(]] .. CapFirst(Tr("secret")) .. [[) Revealed Organisation}]])
    Append(out, [[\label{revealed-orga}]])
    Append(out, itemsParagraph())
    if IsShowFuture then
        Append(out, [[\subsubsection{Unborn Organisation}]])
        Append(out, [[\label{unborn-orga}]])
        Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item{} 10 Vin (]] .. Tr("in-years", { 10 }) .. [[):\\ Founded.\birthof{unborn-orga}]])
        Append(out, [[\end{itemize}]])
        Append(out, itemsParagraph())
    end

    Append(out, [[\chapter{]] .. CapFirst(Tr("items")) .. [[}]])
    Append(out, [[\section{]] .. CapFirst(Tr("items")) .. [[}]])
    Append(out, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ ]] .. CapFirst(Tr("items")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{at-secret-location}]])
    Append(out, [[\item{} \nameref{normal}]])
    Append(out, [[\item{} \nameref{revealed}]])
    if IsShowFuture then
        Append(out, [[\item{} \nameref{unborn}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsection{]] .. CapFirst(Tr("in-whole-world")) .. [[}]])

    Append(out, [[\subsubsection{Normal}]])
    Append(out, [[\label{normal}]])
    Append(out, affiliationParagraph())
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} -10 Vin (]] .. Tr("years-ago", { 10 }) .. [[):\\ Normal event]])
    if IsShowSecrets then
        Append(out, [[\item{} -9 Vin (]] .. Tr("years-ago", { 9 }) .. [[):\\ Concerns \nameref{secret}]])
    end
    Append(out,
        [[\item{} -8 Vin (]] .. Tr("years-ago", { 8 }) .. [[):\\ Concerns \nameref{revealed}]])
    if IsShowSecrets then
        Append(out, [[\item{} -7 Vin (]] .. Tr("years-ago", { 7 }) .. [[):\\ Concerns \nameref{normal}]])
    end
    Append(out, [[\item{} -6 Vin (]] .. Tr("years-ago", { 6 }) .. [[):\\ Concerns \nameref{normal}]])
    if IsShowSecrets then
        Append(out,
            [[\item{} -5 Vin (]] .. Tr("years-ago", { 5 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Secret event]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsubsection[Revealed]{(]] .. CapFirst(Tr("secret")) .. [[) Revealed}]])
    Append(out, [[\label{revealed}]])
    Append(out, affiliationParagraph())
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} -8 Vin (]] .. Tr("years-ago", { 8 }) .. [[):\\ Concerns \nameref{revealed}]])
    Append(out, [[\item{} -6 Vin (]] .. Tr("years-ago", { 6 }) .. [[):\\ Concerns \nameref{normal}]])
    Append(out, [[\end{itemize}]])

    if IsShowFuture then
        Append(out, [[\subsubsection{Unborn}]])
        Append(out, [[\label{unborn}]])
        Append(out, affiliationParagraph())
        Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item{} 10 Vin (]] .. Tr("in-years", { 10 }) .. [[):\\ Created.\birthof{unborn}]])
        Append(out, [[\end{itemize}]])
    end

    if IsShowSecrets then
        Append(out, [[\subsection{]] .. CapFirst(Tr("in")) .. [[ Eldorado}]])
    else
        Append(out, [[\subsection{]] .. CapFirst(Tr("at-secret-locations")) .. [[}]])
    end
    Append(out, [[\subsubsection{At secret Location}]])
    Append(out, [[\label{at-secret-location}]])
    Append(out, affiliationParagraph())
    if IsShowSecrets then
        Append(out, [[\chapter{]] .. CapFirst(Tr("only-mentioned")) .. [[}]])
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

CurrentYear = 0
local out = {}
local expected = {}

IsShowSecrets = false
IsShowFuture = false
out = AutomatedChapters()
expected = generateExpected()
Assert("entity-visibility-no-secrets-no-future", expected, out)

IsShowSecrets = true
IsShowFuture = false
out = AutomatedChapters()
expected = generateExpected()
Assert("entity-visibility-with-secrets-no-future", expected, out)

IsShowSecrets = false
IsShowFuture = true
out = AutomatedChapters()
expected = generateExpected()
Assert("entity-visibility-no-secrets-with-future", expected, out)

IsShowSecrets = true
IsShowFuture = true
out = AutomatedChapters()
expected = generateExpected()
Assert("entity-visibility-with-secrets-with-future", expected, out)
