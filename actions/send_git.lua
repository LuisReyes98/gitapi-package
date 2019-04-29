event = ["git_requested"]
priority = 1
input_parameters = ["request"]

-- 
--  GIT HUB request tests
-- 



local query = "lighttouch"

local my_response = nil

-- local luasocket = require "socket"

-- uri="https://api.github.com/search/issues?page=2&per_page=10&q={%22".. query .."%22}&client_id=".. settings.github_client_id .. "&client_secret="..settings.github_client_secret .."",

-- my_response = send_request({
--   uri="https://api.github.com/search/issues?q={\"lighttouch\"}",
--   method="GET",
--   headers={
--     ["accept"]="application/vnd.github.v3.raw+json",
--     ["Accept"]="application/vnd.github.v3.raw+json",
--   },
--   params='{"client_id": "'.. settings.github_client_id ..'"'..
--     ',"client_secret": "'.. settings.github_client_secret ..'"'..
--     ', "q": "'.. query ..'"'..
--     ', "accept": "application/vnd.github.v3+json" }',

-- })

-- my_response = send_request({
--   uri="https://api.github.com/search/issues?q={\"lighttouch\"}&client_secret=".. settings.github_client_secret .. "&client_id="..settings.github_client_id,
--   method="GET",
--   headers={
--     ["content-type"]="application/json"
--   },
--   body=''

-- })

-- Health checkup of query

-- my_response = send_request({
--   uri="https://api.github.com:443",
--   method="GET",
-- })


-- Quote Api for testing 
-- my_response = send_request({
--   uri="http://ron-swanson-quotes.herokuapp.com/v2/quotes",
--   method="GET",
-- })


-- JSON HTTPS Api for testing 
-- local http = require "luarocks.rocks.socket.http"

-- my_response = send_request({
--   uri="https://jsonplaceholder.typicode.com/todos/1",
--   method="GET",
--   headers={
--     ["content-type"]="application/json"
--   },
-- })


-- -- 
-- -- 
-- -- 
-- local homepage = render("index.html", {
--   SITE_URL = "/",
--   SITENAME = "GIT DISPLAY",
--   client_id = settings.github_client_id,
--   git_response = my_response,
-- })



return {
  status = 200,
  headers = {
    ["content-type"] = "text/html",
  },
  body = homepage

}
