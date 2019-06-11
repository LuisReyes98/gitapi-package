event = ["git_requested"]
priority = 1
input_parameters = ["request"]

--
--  GIT HUB request
--
-- local query = "lighttouch"
-- dummy data url https://api.github.com/search/issues?q={lighttouch}&page=1&per_page=10

-- response data and centinel variables
local cleaned_data
local processed_request = false
local processed_headers = false
local pages_header = {}
local total_pages = 0

-- query data
local dataPerPage = 10

local search_for
local current_page
local labels_search

if request.query.page then
  current_page = tonumber(request.query.page)
else
  current_page = 1
end

if request.query.search_for then
  search_for = request.query.search_for
else
  search_for = ""
end

if request.query.labels then
  labels_search = request.query.labels
else
  labels_search = ""
end

-- local API_URL = "https://api.github.com/search/issues?q={%22".. search_for .."%22}"
function addParameterToURL( url,name,value)
  local url_c = url

  if string.find(url_c,"?") then
    url_c = url_c .. "&" .. name .. "=" .. value
  else
    url_c = url_c .. "?" .. name .. "=" .. value
  end

  return url_c
end

function githubApiV3GetRequest(url)
  local response
  -- Authenticating app in order to increase the requests to the api

  if settings.github_client_id then
    url = addParameterToURL(url,"client_id",settings.github_client_id)
  end

  if settings.github_client_secret then
    url = addParameterToURL(url,"client_secret",settings.github_client_secret)
  end

  -- safe call
  status, response = pcall(send_request,{ -- get request to github API
    uri = url,
    method = "GET",
    headers = {
      ["content-type"] = "application/json",
      ["accept"] = "application/vnd.github.v3+json", -- to certified that is calling git hub api v3
    },
  })
  if status then
    return {
      error = not status,
      api_request_status = 200,
      message = response,
    }
  else
    return {
      error = not status,
      api_request_status = 500,
      message = response,

    }
  end


end


function valuePrescenceCheck( value )
  if value then
    return value
  else
    return ""
  end
  -- body
end


function labelWrapper(labels)
  -- labels : an array of issue labels from the github api
  -- returns a string with all the labels separated by ,
  local labelString = ""
  for key,value in pairs(labels) do
    labelString = labelString .. value.name .. ",\n" --combines all labels separated by a comma "," and a new line
  end
  return labelString
end


function commentsWrapper( amount_of_comments, comments_reference )
  local comments_string = ""

  if amount_of_comments >= 1 then
    local comments = githubApiV3GetRequest(comments_reference) --request
    if not comments.error then --if not errors in entry
      for key,value in pairs(comments.message.body) do --for every entry
        if value.user and value.body then --if the entry has proper format , sometimes the api do to excessive requests wont do it 
          comments_string = comments_string .."(" .. value.created_at .. ") " .. value.user.login .. ": \n" .. value.body .. "\n" --formatting comments in one text string
        elseif value.message then --if the api responds with a message show it 
          return value.message
        else --if no format or not entries found return empty
          return ""
        end
      end
    else
      return "" -- if the request failed to be excuted return empty
    end
  end

  return comments_string
end


function assigneesWrapper(assignees)
  -- prepares a string with all the assignees names
  assigneesString = ""
  if not next(assignees) == nil then
    -- assignees is NOT empty
    for assigned in assignees do
      assigneesString = assigneesString .. assigned.login .. ",\n"
    end
  end

  return assigneesString
end


function split(s, delimiter)--split a string
  result = {};
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match);
  end
  return result;
end

function labelsSearchQuery( labels)
  local labelToSearch = ""
  if labels ~= "" then
    local labelString = split(labels,",")
    for i,value in pairs(labelString) do
      if value ~= "" then
        labelToSearch = labelToSearch .. " label:\"" .. value .. "\""
      end
    end
  end
  return labelToSearch

end

function loadGithubApiData()
  -- function to load the data of ISSUES from the github api
  local data = {} -- declaring table to return
  data.body = {}
  data.headers = {}

  local API_URL = "https://api.github.com/search/issues?q={".. search_for .. labelsSearchQuery(labels_search) .."}&page=".. current_page .."&per_page=" .. dataPerPage

  local response = githubApiV3GetRequest(API_URL)

  if not response.error then

    for key,value in pairs(response.message.body.items) do
      --[[
        for each issue in the response load a table with the issue data
        with the following parameters
        it is important that if a parameter is empty for it to equals to an empty string
        like thie: "" , and not to nil value , because this will mess with the column format
        in the front end , since lua tables won't store  key that equals to nil
      ]]
      table.insert(data.body,{
        title = value.title, --title of the issue
        status = value.state, -- status of the issue open or close
        body = value.body, -- main information of the issue
        issue_url = value.html_url, -- url of the issue in git hub
        creator = value.user.login, -- username of the creator of the issue
        is_locked = value.locked, -- false if the issue is not locked
        created_at = value.created_at, -- date of creation
        updated_at = value.updated_at, -- date of last update
        closed_at = valuePrescenceCheck(value.closed_at), -- date in which the issue closed , empty if it is still open
        labels = labelWrapper(value.labels), -- labels that mark the issue
        author_association = value.author_association, -- association of the creator of the issue with the issue itself ex: member , manager,colaborator etc..
        comments = commentsWrapper(value.comments,value.comments_url), -- comments of  the issue in the format (date)username: \n comment \n *repeat*
        assignees = assigneesWrapper(value.assignees)-- usernames of  people assigned to the issue
      })
    end --endfor
    -- data.headers = response.message.headers.link
    data.total_count = response.message.body.total_count
  else
    return response
  end
  return data
end

function calculatePageCount( total_items, items_per_page )
  local floatNum = total_items / items_per_page
  local num = math.floor(floatNum)
  if floatNum > num  then
    num = num + 1
  end
  return num
end

processed_request, cleaned_data = pcall(loadGithubApiData) --main call to the search method

if processed_request then
  total_calculated, total_pages = pcall(calculatePageCount,tonumber(cleaned_data.total_count) ,dataPerPage)
  if not total_calculated then
    total_pages = 0
  end
end

-- --
-- --
-- --
local page = render("gitindex.html", {
  SITENAME = "GIT DISPLAY",
  issue_table_id = "my_super_original_id", -- be sure it is an string
  server_response = json.from_table(cleaned_data.body) ,
  processed_request = processed_request,
  search_for = search_for,
  total_pages = total_pages,
  current_page = current_page,
  labels_search = labels_search,
})

return {
  status = 200,
  headers = {
    ["content-type"] = "text/html",
  },
  body = page
}
