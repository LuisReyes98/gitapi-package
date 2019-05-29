event = ["git_requested"]
priority = 1
input_parameters = ["request"]

-- 
--  GIT HUB request
-- 
-- local query = "lighttouch"
-- dummy data url https://api.github.com/search/issues?q={%22lighttouch%22}&page=1&per_page=3
local cleaned_data
local URI_URL = "https://api.github.com/search/issues?q={%22lighttouch%22}&page=1&per_page=3"

function githubApiV3GetRequest(url)
  return send_request({ -- get request to github API
    uri = url,
    method = "GET",
    headers = {
      ["content-type"] = "application/json",
      ["accept"] = "application/vnd.github.v3+json", -- to certified that is calling git hub api v3 
      ["Accept"] = "application/vnd.github.v3+json", -- to certified that is calling git hub api v3 
    },
  })
end

-- The cleaned data will be an array in which every position will have the following
--[[
  "Status",+
  "Title",+
  "Body",+
  "issue_url",+
  "Labels",+
  "Creator",+
  "Locked",+
  "Assignees",
  "Comments",
  "Author association",
  "Created at",+
  "Updated at",+
  "Closed at",+
  ]]
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
    labelString = labelString .. value.name .. ",\n"
  end
  return labelString
end

function loadGithubApiData()
  -- function to load the data of ISSUES from the github api
  local data = {} -- declaring table to return

  local response = githubApiV3GetRequest(URI_URL)

  for key,value in pairs(response.body.items) do 
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
    })

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
