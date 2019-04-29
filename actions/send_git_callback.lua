event = ["git_callback_requested"]
priority = 1
input_parameters = ["request"]

-- 
--  GIT HUB request tests
-- 

-- local git_response = send_request({
--   uri="https://github.com/login/oauth/access_token",
--   method="POST",
--   headers={
--     ["accept"]="application/vnd.github.v3+json",
--     ["Accept"]="application/vnd.github.v3+json",
--   },
--   body='{"client_id": "'.. settings.github_client_id ..
--     '", "client_secret": "'.. settings.github_client_secret ..
--     '", "code": "'.. request.query.code ..
--     '", "accept": "application/json" }',
-- })


local homepage = render("index.html", {
  SITENAME = "GIT CALLBACK",
  -- client_id = settings.github_client_id, 
  -- code = request.query.code,
  -- git_response = git_response,  
})


-- return homepage_requested

return {
  status = 200,
  headers = {
    ["content-type"] = "text/html",
  },
  body = homepage

}
