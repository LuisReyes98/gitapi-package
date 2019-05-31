event = ["git_requested"]
priority = 1
input_parameters = ["request"]

-- 
--  GIT HUB request
-- 
-- local query = "lighttouch"
-- dummy data url https://api.github.com/search/issues?q={%22lighttouch%22}&page=1&per_page=3
local cleaned_data

local searchKeyword = "lighttouch"
local dataPerPage = 10
local pageNumber = 1

local URI_URL = "https://api.github.com/search/issues?q={%22".. searchKeyword .."%22}&page=".. pageNumber .."&per_page=" .. dataPerPage

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
    local comments = githubApiV3GetRequest(comments_reference)
    if not comments.error then
      for key,value in pairs(comments.message.body) do
        comments_string = comments_string .."(" .. value.created_at .. ") " .. value.user.login .. ": \n" .. value.body .. "\n"
      end
    else
      return ""
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
      --[[for each issue in the response load a table with the issue data
        with the following parameters
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

cleaned_data = loadGithubApiData()

-- -- 
-- -- 
-- -- 
local homepage = render("gitindex.html", {
  SITENAME = "GIT DISPLAY",
  issue_table_id = "my_super_original_id", -- be sure it is an string 
  git_response = json.from_table(cleaned_data),
})

return {
  status = 200,
  headers = {
    ["content-type"] = "text/html",
  },
  body = homepage
  
}
