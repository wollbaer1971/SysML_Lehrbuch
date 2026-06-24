-- epub_filter.lua
-- Pandoc Lua-Filter: wandelt marker-annotierte BlockQuotes
-- in gestylte Div-Elemente um.
--
-- Voraussetzung: Der Python-Preprocessor hat die Custom-Environments
-- bereits in  \begin{quote}\textbf{KLASSENNAME}...\end{quote}  umgewandelt.

local BOX_CLASSES = {
  lernziele  = true,
  praxisbox  = true,
  hinweisbox = true,
  uebungbox  = true,
}

local BOX_TITLES = {
  lernziele  = "Lernziele",
  praxisbox  = "Praxisbeispiel",
  hinweisbox = "Hinweis",
  uebungbox  = "Übung",
}

function BlockQuote(el)
  local first = el.content[1]
  if not (first and first.t == "Para") then return el end

  local first_inline = first.content[1]
  if not (first_inline and first_inline.t == "Strong") then return el end

  local str_node = first_inline.content[1]
  if not (str_node and str_node.t == "Str") then return el end

  local class = str_node.text
  if not BOX_CLASSES[class] then return el end

  -- Titelzeile mit echtem Titel statt rohem Klassennamen
  local title_para = pandoc.Para({
    pandoc.Strong({ pandoc.Str(BOX_TITLES[class]) })
  })

  -- Restinhalt (ohne den Marker-Absatz)
  local body = { title_para }
  for i = 2, #el.content do
    body[#body + 1] = el.content[i]
  end

  return pandoc.Div(body, pandoc.Attr("", { class }, {}))
end
