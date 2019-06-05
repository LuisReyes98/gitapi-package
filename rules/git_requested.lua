priority = 2
input_parameter = "request"
events_table = ["git_requested"]

request.path_segments[1] == "git"
and
#request.path_segments == 1
and
request.method == "GET"
or
request.query.search_for
or
request.query.page