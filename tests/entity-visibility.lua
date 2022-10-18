NewEntity("normal", "item", nil, "Normal")
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddEvent(CurrentEntity(), -9, [[Concerns \reference{secret}]])
AddEvent(CurrentEntity(), -8, [[Concerns \reference{revealed}]])
AddRef("normal", PrimaryRefs)

NewEntity("secret", "item", nil, "Secret")
SetSecret(CurrentEntity())
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddEvent(CurrentEntity(), -7, [[Concerns \reference{normal}]])

NewEntity("revealed", "item", nil, "Revealed")
SetSecret(CurrentEntity())
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddEvent(CurrentEntity(), -6, [[Concerns \reference{normal}]])
Reveal("revealed")

NewEntity("unborn", "item", nil, "Unborn")
AddEvent(CurrentEntity(), 10, [[Created.\birthof{unborn}]])
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddRef("unborn", PrimaryRefs)

NewEntity("at-secret-location", "item", nil, "At secret Location")
SetDescriptor(CurrentEntity(), "location", "eldorado")
AddAssociation(CurrentEntity(), "normal-orga")
AddAssociation(CurrentEntity(), "secret-orga")
AddAssociation(CurrentEntity(), "revealed-orga")
AddAssociation(CurrentEntity(), "unborn-orga")
AddRef("at-secret-location", PrimaryRefs)

NewEntity("eldorado", "place", nil, "Eldorado")
SetSecret(CurrentEntity())

NewEntity("normal-orga", "organisation", nil, "Normal Organisation")
AddRef("normal-orga", PrimaryRefs)

NewEntity("secret-orga", "organisation", nil, "Secret Organisation")
SetSecret(CurrentEntity())

NewEntity("revealed-orga", "organisation", nil, "Revealed Organisation")
SetSecret(CurrentEntity())
Reveal("revealed-orga")

NewEntity("unborn-orga", "organisation", nil, "Unborn Organisation")
AddEvent(CurrentEntity(), 10, [[Founded.\birthof{unborn-orga}]])
AddRef("unborn-orga", PrimaryRefs)

local function itemsParagraph()
    local out = {}
    Append(out, [[\paragraph{Gegenstände}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{at-secret-location} (an unbekanntem Ort)]])
    Append(out, [[\item{} \nameref{normal}]])
    Append(out, [[\item{} \nameref{revealed} (Geheim)]])
    if IsShowSecrets then
        Append(out, [[\item{} \nameref{secret} (Geheim)]])
    end
    if IsShowFuture then
        Append(out, [[\item{} \nameref{unborn}]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function associationParagraph()
    local out = {}
    Append(out, [[\paragraph{Zusammenschlüsse}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} (Geheim) Mitglied der \nameref{revealed-orga}.]])
    if IsShowSecrets then
        Append(out, [[\item{} (Geheim) Mitglied der \nameref{secret-orga}.]])
    end
    Append(out, [[\item{} Mitglied der \nameref{normal-orga}.]])
    if IsShowFuture then
        Append(out, [[\item{} Mitglied der \nameref{unborn-orga}.]])
    end
    Append(out, [[\end{itemize}]])
    return out
end

local function generateExpected()
    local out = {}
    Append(out, [[\chapter{Zusammenschlüsse}]])
    Append(out, [[\section*{Alle Zusammenschlüsse}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{normal-orga}]])
    Append(out, [[\item{} \nameref{revealed-orga}]])
    if IsShowFuture then
        Append(out, [[\item{} \nameref{unborn-orga}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\section{Organisationen}]])
    Append(out, [[\subsection{In der ganzen Welt}]])
    Append(out, [[\subsubsection{Normal Organisation}]])
    Append(out, [[\label{normal-orga}]])
    Append(out, itemsParagraph())
    Append(out, [[\subsubsection[Revealed Organisation]{(Geheim) Revealed Organisation}]])
    Append(out, [[\label{revealed-orga}]])
    Append(out, itemsParagraph())
    if IsShowFuture then
        Append(out, [[\subsubsection{Unborn Organisation}]])
        Append(out, [[\label{unborn-orga}]])
        Append(out, itemsParagraph())
    end

    Append(out, [[\chapter{Gegenstände}]])
    Append(out, [[\section*{Alle Gegenstände}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} \nameref{at-secret-location}]])
    Append(out, [[\item{} \nameref{normal}]])
    Append(out, [[\item{} \nameref{revealed}]])
    if IsShowFuture then
        Append(out, [[\item{} \nameref{unborn}]])
    end
    Append(out, [[\end{itemize}]])

    Append(out, [[\section{Gegenstände}]])
    Append(out, [[\subsection{In der ganzen Welt}]])

    Append(out, [[\subsubsection{Normal}]])
    Append(out, [[\label{normal}]])
    Append(out, [[\paragraph{Histori\"e}]])
    Append(out, [[\begin{itemize}]])
    if IsShowSecrets then
        Append(out, [[\item{} -9 Vin (vor 9 Jahren): (Geheim) Concerns \nameref{secret}]])
    end
    Append(out, [[\item{} -8 Vin (vor 8 Jahren): (Geheim) Concerns \nameref{revealed}]])
    if IsShowSecrets then
        Append(out, [[\item{} -7 Vin (vor 7 Jahren): (Geheim) Concerns \nameref{normal}]])
    end
    Append(out, [[\item{} -6 Vin (vor 6 Jahren): (Geheim) Concerns \nameref{normal}]])
    Append(out, [[\end{itemize}]])
    Append(out, associationParagraph())

    Append(out, [[\subsubsection[Revealed]{(Geheim) Revealed}]])
    Append(out, [[\label{revealed}]])
    Append(out, [[\paragraph{Histori\"e}]])
    Append(out, [[\begin{itemize}]])
    Append(out, [[\item{} -8 Vin (vor 8 Jahren): (Geheim) Concerns \nameref{revealed}]])
    Append(out, [[\item{} -6 Vin (vor 6 Jahren): (Geheim) Concerns \nameref{normal}]])
    Append(out, [[\end{itemize}]])
    Append(out, associationParagraph())

    if IsShowFuture then
        Append(out, [[\subsubsection{Unborn}]])
        Append(out, [[\label{unborn}]])
        Append(out, [[\paragraph{Histori\"e}]])
        Append(out, [[\begin{itemize}]])
        Append(out, [[\item{} -7 Vin (vor 7 Jahren): (Geheim) Concerns \nameref{normal}]])
        Append(out, [[\end{itemize}]])
        Append(out, associationParagraph())
    end

    if IsShowSecrets then
        Append(out, [[\subsection{In Eldorado}]])
    else
        Append(out, [[\subsection{An geheimen Orten}]])
    end
    Append(out, [[\subsubsection{At secret Location}]])
    Append(out, [[\label{at-secret-location}]])
    Append(out, associationParagraph())
    if IsShowSecrets then
        Append(out, [[\chapter{Nur erwähnt}]])
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

IsShowSecrets = false
IsShowFuture = false
local out = AutomatedChapters()
local expected = generateExpected()
Assert("entity-visibility-no-secrets-no-future", expected, out)

IsShowSecrets = true
IsShowFuture = false
local out = AutomatedChapters()
local expected = generateExpected()
Assert("entity-visibility-with-secrets-no-future", expected, out)

IsShowSecrets = false
IsShowFuture = true
local out = AutomatedChapters()
local expected = generateExpected()
Assert("entity-visibility-no-secrets-with-future", expected, out)

IsShowSecrets = true
IsShowFuture = true
local out = AutomatedChapters()
local expected = generateExpected()
Assert("entity-visibility-with-secrets-with-future", expected, out)
