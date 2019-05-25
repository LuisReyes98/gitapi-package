event = ["git_requested"]
priority = 1
input_parameters = ["request"]

-- 
--  GIT HUB request
-- 

-- local query = "lighttouch"
-- dummy data url https://api.github.com/search/issues?q={%22lighttouch%22}&page=1&per_page=3
local cleaned_data = {}

local URI_URL = "https://api.github.com/search/issues?q={%22lighttouch%22}&page=1&per_page=3"

local git_response = send_request({
  uri = URI_URL,
  method = "GET",
  headers = {
    ["content-type"] = "application/json",
    ["accept"] = "application/vnd.github.v3+json", --git hub api v3 
    ["Accept"] = "application/vnd.github.v3+json", --git hub api v3 
  },
})

log.debug("Start of data cleaning")
-- The cleaned data will be an array in which every position will have the following
-- "Status","Title","Body","Subject","Labels","Creator","Locked","Assignees","Comments","Author association","Created at","Updated at","Closed at",



for key,value in pairs(git_response.body.items) do
  table.insert(cleaned_data,{title = value.title}) 
  -- log.debug('key:')
  -- log.debug(k)
  -- log.debug('value:')
  -- log.debug(v)
end
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
