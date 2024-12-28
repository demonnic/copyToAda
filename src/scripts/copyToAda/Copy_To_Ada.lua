local config = {
  fontSize = 16,
  backgroundColor = "black",
  defaultTitle = "Hey! Listen!",
  apiKey = "https://ada-young.com/pastebin/api/v1/about",
}

local htmlHeader = [=[  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
    <link href='http://fonts.googleapis.com/css?family=Droid+Sans+Mono' rel='stylesheet' type='text/css'>
    <style type="text/css">
      body {
        background-color: ]=] .. config.backgroundColor .. [=[;
        font-family: 'Droid Sans Mono';
        white-space: pre; 
        font-size: ]=] .. config.fontSize.. [=[px;
      }
    </style>
  </head>
<body><span>
]=]

local headers = {
  ["Authorization"] = "Bearer " .. config.apiKey,
  ["Content-Type"] = "application/json",
}

local aboutURL = "https://ada-young.com/pastebin/api/v1/about"

local url = "https://ada-young.com/pastebin/api/v1/create"

local function getSelectedTextHTML(window, startCol, startRow, endCol, endRow)
  -- Check whether there's an actual selection
  if startCol == endCol and startRow == endRow then return "" end
  local parsed = ""
  -- Loop through each symbol within the range
  for lineNum = startRow, endRow do
    local cStart = lineNum == startRow and startCol or 0
    moveCursor(window, cStart, lineNum)
    local cEnd = lineNum == endRow and endCol or #getCurrentLine() - 1
    selectSection(window, cStart, cEnd - cStart + 1)
    local str = getSelection(window) or ""
    local htmlStr = str == "" and "" or copy2html(window, str)
    parsed = parsed .. htmlStr
    if lineNum ~= endRow then parsed = parsed .. "<br>  " end
  end
  return parsed
end

local handler = function(event, menu, ...)
  if config.apiKey == aboutURL then
    cecho("\n<white>[<pink>Ada<white>]: You need to configure the api key at the top of the Copy to Ada script for this to work.\n")
    cecho("<white>[<pink>Ada<white>]: Visit ")
    echoLink(aboutURL, [[openUrl("]] .. aboutURL .. [[")]], "Click to get API Key")
    echo(" and it will either tell you your API key or that you can get one by logging in.\n")
    return
  end
  local text = getSelectedTextHTML(...)
  text = htmlHeader .. text
  local data = {
    content = text,
    format = "html",
    title = config.defaultTitle,
  }
  cecho("\n<white>[<pink>Ada<white>]: Attempting to paste... please wait!\n")
  postHTTP(yajl.to_string(data), url, headers)
end
local function postHandler(eventName, one, two)
  if eventName == "sysPostHttpDone" then
    if one ~= url then return end
    local response = yajl.to_value(two)
    cecho("\n<white>[<pink>Ada<white>]: Success! " ..response.url .. "\n")
  else
    if two ~= url then return end
    cecho("\n<white>[<pink>Ada<white>]: Oops, error! " ..one)
  end
end
registerNamedEventHandler("demonnic", "adaSuccess", "sysPostHttpDone", postHandler)
registerNamedEventHandler("demonnic", "adaFailure", "sysPostHttpError", postHandler)
addMouseEvent("Send to ada-young.com/pastebin", "sendToAdaYoung")
registerNamedEventHandler("demonnic", "send to ada-young", "sendToAdaYoung", handler)

