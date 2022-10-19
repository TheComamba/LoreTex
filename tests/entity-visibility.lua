NewEntity("normal", "items", nil, "Normal")
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddEvent(CurrentEntity(), -9, [[Concerns \reference{secret}]])
AddEvent(CurrentEntity(), -8, [[Concerns \reference{revealed}]])
AddEvent(CurrentEntity(), -5, [[Secret event]], 0, true)
AddRef("normal", PrimaryRefs)

NewEntity("secret", "items", nil, "Secret")
SetSecret(CurrentEntity())
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddEvent(CurrentEntity(), -7, [[Concerns \reference{normal}]])

NewEntity("revealed", "items", nil, "Revealed")
SetSecret(CurrentEntity())
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddEvent(CurrentEntity(), -6, [[Concerns \reference{normal}]])
Reveal("revealed")

NewEntity("unborn", "items", nil, "Unborn")
AddEvent(CurrentEntity(), 10, [[Created.\birthof{unborn}]])
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddRef("unborn", PrimaryRefs)

NewEntity("at-secret-location", "items", nil, "At secret Location")
SetDescriptor(CurrentEntity(), "location", "eldorado")
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddRef("at-secret-location", PrimaryRefs)

NewEntity("eldorado", "places", nil, "Eldorado")
SetSecret(CurrentEntity())

NewEntity("normal-orga", "organisations", nil, "Normal Organisation")
AddRef("normal-orga", PrimaryRefs)

NewEntity("secret-orga", "organisations", nil, "Secret Organisation")
SetSecret(CurrentEntity())

NewEntity("revealed-orga", "organisations", nil, "Revealed Organisation")
SetSecret(CurrentEntity())
Reveal("revealed-orga")

NewEntity("unborn-orga", "organisations", nil, "Unborn Organisation")
AddEvent(CurrentEntity(), 10, [[Founded.\birthof{unborn-orga}]])
AddRef("unborn-orga", PrimaryRefs)

local function itemsParagraph()
    local out = {}
    Append(out, [[\paragraph{Items}]])
    Append(out, [[\begin{itemize}]])
    if IsShowSecrets then
        Append(out, [[\item{} \nameref{at-secret-location} (in \nameref{eldorado})]])
    else
        Append(out, [[\item{} \nameref{at-secret-location} (at secret location)]])
    end
    Append(out, [[\item{} \nameref{normal}]])
    Append(out, [[\item{} \nameref{revealed} (Secret)]])
    if IsShowSecrets then
        Append(out, [[\item{} \nameref{secret} (Secret)]])
    end
    if IsShowFuture then
        Append(out, [[\item{} \nameref{unborn}]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function associationParagraph()
    local out = {}
    Append(out, [[\paragraph{Associations}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} (Secret) Member of \nameref{revealed-orga}.]])
    if IsShowSecrets then
        Append(out, [[\item{} (Secret) Member of \nameref{secret-orga}.]])
    end
    Append(out, [[\item{} Member of \nameref{normal-orga}.]])
    if IsShowFuture then
        Append(out, [[\item{} Member of \nameref{unborn-orga}.]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function generateExpected()
    local out = {}
    Append(out, [[\chapter{Associations}]])
    Append(out, [[\section*{All Associations}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{normal-orga}]])
    Append(out, [[\item{} \nameref{revealed-orga}]])
    if IsShowFuture then
        Append(out, [[\item{} \nameref{unborn-orga}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\section{Organisations}]])
    Append(out, [[\subsection{In the whole World}]])
    Append(out, [[\subsubsection{Normal Organisation}]])
    Append(out, [[\label{normal-orga}]])
    Append(out, itemsParagraph())
    Append(out, [[\subsubsection[Revealed Organisation]{(Secret) Revealed Organisation}]])
    Append(out, [[\label{revealed-orga}]])
    Append(out, itemsParagraph())
    if IsShowFuture then
        Append(out, [[\subsubsection{Unborn Organisation}]])
        Append(out, [[\label{unborn-orga}]])
        Append(out, itemsParagraph())
    end

    Append(out, [[\chapter{Items}]])
    Append(out, [[\section*{All Items}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{at-secret-location}]])
    Append(out, [[\item{} \nameref{normal}]])
    Append(out, [[\item{} \nameref{revealed}]])
    if IsShowFuture then
        Append(out, [[\item{} \nameref{unborn}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\section{Items}]])
    Append(out, [[\subsection{In the whole World}]])

    Append(out, [[\subsubsection{Normal}]])
    Append(out, [[\label{normal}]])
    Append(out, [[\paragraph{History}]])
    Append(out, [[\begin{itemize}]])
    if IsShowSecrets then
        Append(out, [[\item{} -9 Vin (9 years ago): (Secret) Concerns \nameref{secret}]])
    end
    Append(out, [[\item{} -8 Vin (8 years ago): (Secret) Concerns \nameref{revealed}]])
    if IsShowSecrets then
        Append(out, [[\item{} -7 Vin (7 years ago): (Secret) Concerns \nameref{normal}]])
    end
    Append(out, [[\item{} -6 Vin (6 years ago): (Secret) Concerns \nameref{normal}]])
    if IsShowSecrets then
        Append(out, [[\item{} -5 Vin (5 years ago): (Secret) Secret event]])
    end
    Append(out, [[\end{itemize}]])
    Append(out, associationParagraph())

    Append(out, [[\subsubsection[Revealed]{(Secret) Revealed}]])
    Append(out, [[\label{revealed}]])
    Append(out, [[\paragraph{History}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} -8 Vin (8 years ago): (Secret) Concerns \nameref{revealed}]])
    Append(out, [[\item{} -6 Vin (6 years ago): (Secret) Concerns \nameref{normal}]])
    Append(out, [[\end{itemize}]])
    Append(out, associationParagraph())

    if IsShowFuture then
        Append(out, [[\subsubsection{Unborn}]])
        Append(out, [[\label{unborn}]])
        Append(out, [[\paragraph{History}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item{} -7 Vin (7 years ago): (Secret) Concerns \nameref{normal}]])
        Append(out, [[\end{itemize}]])
        Append(out, associationParagraph())
    end

    if IsShowSecrets then
        Append(out, [[\subsection{In Eldorado}]])
    else
        Append(out, [[\subsection{At secret Location}]])
    end
    Append(out, [[\subsubsection{At secret Location}]])
    Append(out, [[\label{at-secret-location}]])
    Append(out, associationParagraph())
    if IsShowSecrets then
        Append(out, [[\chapter{Only mentioned}]])
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

CurrentYearVin = 0
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
