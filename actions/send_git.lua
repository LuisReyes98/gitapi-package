event = ["git_requested"]
priority = 1
input_parameters = ["request"]

-- 
--  GIT HUB request
-- 
-- local query = "lighttouch"
-- dummy data url https://api.github.com/search/issues?q={%22lighttouch%22}&page=1&per_page=3
local cleaned_data
local processed_request = false
local processed_to_json = false
local search_for

-- local searchKeyword = ""
-- local searchKeyword = "lighttouch"
if request.query.search_for then
  search_for = request.query.search_for
else 
  search_for = ""
end

-- local searchKeyword = "light"
local dataPerPage = 10
local pageNumber = 1

local URI_URL = "https://api.github.com/search/issues?q={%22".. search_for .."%22}&page=".. pageNumber .."&per_page=" .. dataPerPage


function githubApiV3GetRequest(url)
  local response
  -- safe call
  status, response = pcall(send_request,{ -- get request to github API
    uri = url,
    method = "GET",
    headers = {
      ["content-type"] = "application/json",
      ["accept"] = "application/vnd.github.v3+json", -- to certified that is calling git hub api v3 
      ["Accept"] = "application/vnd.github.v3+json", -- to certified that is calling git hub api v3 
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
          -- body
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

-- The cleaned data will be an array in which every position will have the following
--[[ Table fields list
  "Status",+
  "Title",+
  "Body",+
  "issue_url",+
  "Labels",+
  "Creator",+
  "Locked",+

  "Assignees",

  "Comments",+
  "Author association",+
  "Created at",+
  "Updated at",+
  "Closed at",+
  ]]

function loadGithubApiData()
  -- function to load the data of ISSUES from the github api
  local data = {} -- declaring table to return
  
  local response = githubApiV3GetRequest(URI_URL)

  if not response.error then
    -- body
    for key,value in pairs(response.message.body.items) do 
      --[[
        for each issue in the response load a table with the issue data
        with the following parameters
        
        it is important that if a parameter is empty for it to equals to an empty string
        like thie: "" , and not to nil value , because this will mess with the column format
        in the front end , since lua tables won't store  key that equals to nil
      ]]     
      table.insert(data,{
        title = value.title,
        status = value.state,
        body = value.body,
        issue_url = value.html_url,
        creator = value.user.login,
        is_locked = value.locked,
        created_at = value.created_at,
        updated_at = value.updated_at,
        closed_at = valuePrescenceCheck(value.closed_at),
        labels = labelWrapper(value.labels),
        author_association = value.author_association,
        comments = commentsWrapper(value.comments,value.comments_url),
        assignees = assigneesWrapper(value.assignees)
      })
    end

  else
    return response
  end
  return data
end

processed_request, cleaned_data = pcall(loadGithubApiData)

processed_to_json, cleaned_data = pcall(json.from_table,cleaned_data)
-- -- 
-- -- 
-- -- 
local homepage = render("gitindex.html", {
  SITENAME = "GIT DISPLAY",
  issue_table_id = "my_super_original_id", -- be sure it is an string 
  server_response = cleaned_data ,
  processed_request = processed_request,
  processed_to_json = processed_to_json,
  search_for = search_for,
})

return {
  status = 200,
  headers = {
    ["content-type"] = "text/html",
  },
  body = homepage
  
}
