event = ["git_requested"]
priority = 1
input_parameters = ["request"]

-- 
--  GIT HUB request tests
-- 



local query = "lighttouch"

local my_response = nil


-- -- 
-- -- 
-- -- 
local homepage = render("index.html", {
  SITE_URL = "/",
  SITENAME = "GIT DISPLAY",
})



return {
  status = 200,
  headers = {
    ["content-type"] = "text/html",
  },
  body = homepage

}
