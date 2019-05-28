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

-- The cleaned data will be an array in which every position will have the following
-- "Status","Title","Body","Subject","Labels","Creator","Locked","Assignees","Comments","Author association","Created at","Updated at","Closed at",

function load_github_api_data()
  -- body
  local data = {}
  local response = send_request({
    uri = URI_URL,
    method = "GET",
    headers = {
      ["content-type"] = "application/json",
      ["accept"] = "application/vnd.github.v3+json", --git hub api v3 
      ["Accept"] = "application/vnd.github.v3+json", --git hub api v3 
    },
  })
  for key,value in pairs(response.body.items) do
    table.insert(data,{
      title = value.title,
      status = value.state,
    })

  end

  return data

end

cleaned_data = load_github_api_data()

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
