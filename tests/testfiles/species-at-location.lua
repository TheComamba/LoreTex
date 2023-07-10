TexApi.newEntity { type = "places", label = "tattooine", name = "Tattooine" }

TexApi.newEntity { type = "species", label = "tusken", name = "Tusken" }
TexApi.setLocation("tattooine")

TexApi.newEntity { type = "species", label = "jawa", name = "Jawa" }
TexApi.setLocation("tattooine")

local function refSetup()
    TexApi.makeEntityPrimary("tattooine")
    TexApi.addType { metatype = "places", type = "places" }
end

local expected = {}
Append(expected, [[\chapter{Places}]])
Append(expected, [[\section{Places}]])
Append(expected, [[\subsection*{]] .. CapFirst(Tr("all")) .. [[ Places}]])
Append(expected, [[\begin{itemize}]])
Append(expected, [[\item \nameref{tattooine}]])
Append(expected, [[\end{itemize}]])
Append(expected, [[\subsection{]] .. CapFirst(Tr("in_whole_world")) .. [[}]])
Append(expected, [[\subsubsection{Tattooine}]])
Append(expected, [[\label{tattooine}]])
Append(expected, [[\paragraph{]] .. CapFirst(Tr("affiliated")) .. [[ species}]])
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
