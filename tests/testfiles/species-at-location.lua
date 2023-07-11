TexApi.newEntity { type = "places", label = "tattooine", name = "Tattooine" }

TexApi.newEntity { type = "species", label = "tusken", name = "Tusken" }
TexApi.setLocation("tattooine")

TexApi.newEntity { type = "species", label = "jawa", name = "Jawa" }
TexApi.setLocation("tattooine")

local function refSetup()
    TexApi.makeEntityPrimary("tattooine")
end

local expected = {}
Append(expected, [[\chapter{Places}]])
Append(expected, [[\section*{]] .. CapFirst(Tr("all")) .. [[ Places}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{tattooine}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\section{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsection{Tattooine}]])
Append(expected, [[\label{tattooine}]])
Append(expected, [[\subsubsection{]] .. CapFirst(Tr("affiliated")) .. [[ Species}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{jawa}]])
Append(expected, [[\item \nameref{tusken}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\chapter{]] .. CapFirst(Tr("only_mentioned")) .. [[}]])
Append(expected, [[\subparagraph{Jawa}]])
Append(expected, [[\label{jawa}]])
Append(expected, [[\hspace{1cm}]])
Append(expected, [[\subparagraph{Tusken}]])
Append(expected, [[\label{tusken}]])
Append(expected, [[\hspace{1cm}]])

AssertAutomatedChapters("species-at-location", expected, refSetup)
