event = ["git_requested"]
priority = 1
input_parameters = ["request"]

-- 
--  GIT HUB request tests
-- 

-- dummy data url https://api.github.com/search/issues?q={%22lighttouch%22}&page=1&per_page=3

local query = "lighttouch"

local my_response = settings.github_dummy_response.body

local issue_columns = settings.github_dummy_response.issue_fields

-- local all_labels = {}

-- for item in my_response.items do
--   for label in item.labels do
--     -- labels.concat(label.name)   
--     table.insert(all_labels,label.name)
--   end
-- end


local json_file = fs.read_file('git.json')


-- local parsed_json = json.to_table(json_file)
-- log.debug(inspect(parsed_json))


-- json_file = json.to_table(json_file)

-- -- 
-- -- 
-- -- 
local homepage = render("gitindex.html", {
  SITENAME = "GIT DISPLAY",
  response_json = json.from_table(my_response),
  issue_columns = issue_columns,
  issue_table_id = "my_super_original_id", -- be sure it is an string 
  json_file = json_file,
  -- all_labels = json.from_table(all_labels),
})

return {
  status = 200,
  headers = {
    ["content-type"] = "text/html",
  },
  body = homepage
  
}
