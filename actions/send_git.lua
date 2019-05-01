event = ["git_requested"]
priority = 1
input_parameters = ["request"]

-- 
--  GIT HUB request tests
-- 

-- dummy data url https://api.github.com/search/issues?q={%22lighttouch%22}&page=1&per_page=3

local query = "lighttouch"

local my_response = settings.github_dummy_response.body


-- -- 
-- -- 
-- -- 
local homepage = render("gitindex.html", {
  SITENAME = "GIT DISPLAY",
  response = my_response,
  response_json = json.from_table(my_response),
  issue_table_id = "my_super_original_id", -- be sure it is an string 
})

return {
  status = 200,
  headers = {
    ["content-type"] = "text/html",
  },
  body = homepage

}
