TexApi.newEntity { type = "items", label = "normal", name = "Normal" }
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "normal")
    SetYear(hist, -10)
    SetProtectedField(hist, "event", [[Normal event]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "normal")
    SetYear(hist, -9)
    SetProtectedField(hist, "event", [[Concerns \reference{secret}]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "normal")
    SetYear(hist, -8)
    SetProtectedField(hist, "event", [[Concerns \reference{revealed}]])
    ProcessEvent(hist)
end
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "normal")
    SetYear(hist, -5)
    SetProtectedField(hist, "event", [[Secret event]])
    SetProtectedField(hist, "isSecret", true)
    ProcessEvent(hist)
end
AddRef("normal", PrimaryRefs)

TexApi.newEntity { type = "items", label = "secret", name = "Secret" }
SetSecret(CurrentEntity())
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "secret")
    SetYear(hist, -7)
    SetProtectedField(hist, "event", [[Concerns \reference{normal}]])
    ProcessEvent(hist)
end

TexApi.newEntity { type = "items", label = "revealed", name = "Revealed" }
SetSecret(CurrentEntity())
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "revealed")
    SetYear(hist, -6)
    SetProtectedField(hist, "event", [[Concerns \reference{normal}]])
    ProcessEvent(hist)
end
TexApi.reveal("revealed")

TexApi.newEntity { type = "items", label = "unborn", name = "Unborn" }
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "unborn")
    SetYear(hist, 10)
    SetProtectedField(hist, "event", [[Created.\birthof{unborn}]])
    ProcessEvent(hist)
end
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
AddRef("unborn", PrimaryRefs)

TexApi.newEntity { type = "items", label = "at-secret-location", name = "At secret Location" }
SetLocation(CurrentEntity(), "eldorado")
AddParent(CurrentEntity(), "normal-orga")
AddParent(CurrentEntity(), "secret-orga")
AddParent(CurrentEntity(), "revealed-orga")
AddParent(CurrentEntity(), "unborn-orga")
AddRef("at-secret-location", PrimaryRefs)

TexApi.newEntity { type = "places", label = "eldorado", name = "Eldorado" }
SetSecret(CurrentEntity())

TexApi.newEntity { type = "organisations", label = "normal-orga", name = "Normal Organisation" }
AddRef("normal-orga", PrimaryRefs)

TexApi.newEntity { type = "organisations", label = "secret-orga", name = "Secret Organisation" }
SetSecret(CurrentEntity())

TexApi.newEntity { type = "organisations", label = "revealed-orga", name = "Revealed Organisation" }
SetSecret(CurrentEntity())
TexApi.reveal("revealed-orga")

TexApi.newEntity { type = "organisations", label = "unborn-orga", name = "Unborn Organisation" }
if true then
    local hist = EmptyHistoryItem()
    SetProtectedField(hist, "originator", "unborn-orga")
    SetYear(hist, 10)
    SetProtectedField(hist, "event", [[Founded.\birthof{unborn-orga}]])
    ProcessEvent(hist)
end
AddRef("unborn-orga", PrimaryRefs)

local function itemsParagraph()
    local out = {}
    Append(out, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ ]] .. Tr("items") .. [[}]])
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
        Append(out, itemsParagraph())
        Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item{} 10 (]] .. Tr("in-years", { 10 }) .. [[):\\ Founded.\birthof{unborn-orga}]])
        Append(out, [[\end{itemize}]])
    end

    Append(out, [[\chapter{]] .. CapFirst(Tr("things")) .. [[}]])
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
    Append(out, [[\item{} -10 (]] .. Tr("years-ago", { 10 }) .. [[):\\ Normal event]])
    if IsShowSecrets then
        Append(out,
            [[\item{} -9 (]] ..
            Tr("years-ago", { 9 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{secret}]])
    end
    Append(out,
        [[\item{} -8 (]] ..
        Tr("years-ago", { 8 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{revealed}]])
    if IsShowSecrets then
        Append(out,
            [[\item{} -7 (]] ..
            Tr("years-ago", { 7 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{normal}]])
    end
    Append(out,
        [[\item{} -6 (]] ..
        Tr("years-ago", { 6 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{normal}]])
    if IsShowSecrets then
        Append(out,
            [[\item{} -5 (]] .. Tr("years-ago", { 5 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Secret event]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\subsubsection[Revealed]{(]] .. CapFirst(Tr("secret")) .. [[) Revealed}]])
    Append(out, [[\label{revealed}]])
    Append(out, affiliationParagraph())
    Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
    Append(out, [[\begin{itemize}]])
    Append(out,
        [[\item{} -8 (]] ..
        Tr("years-ago", { 8 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{revealed}]])
    Append(out,
        [[\item{} -6 (]] ..
        Tr("years-ago", { 6 }) .. [[):\\ (]] .. CapFirst(Tr("secret")) .. [[) Concerns \nameref{normal}]])
    Append(out, [[\end{itemize}]])

    if IsShowFuture then
        Append(out, [[\subsubsection{Unborn}]])
        Append(out, [[\label{unborn}]])
        Append(out, affiliationParagraph())
        Append(out, [[\paragraph{]] .. CapFirst(Tr("history")) .. [[}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item{} 10 (]] .. Tr("in-years", { 10 }) .. [[):\\ Created.\birthof{unborn}]])
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
out = TexApi.automatedChapters()
expected = generateExpected()
Assert("entity-visibility-no-secrets-no-future", expected, out)

IsShowSecrets = true
IsShowFuture = false
out = TexApi.automatedChapters()
expected = generateExpected()
Assert("entity-visibility-with-secrets-no-future", expected, out)

IsShowSecrets = false
IsShowFuture = true
out = TexApi.automatedChapters()
expected = generateExpected()
Assert("entity-visibility-no-secrets-with-future", expected, out)

IsShowSecrets = true
IsShowFuture = true
out = TexApi.automatedChapters()
expected = generateExpected()
Assert("entity-visibility-with-secrets-with-future", expected, out)
