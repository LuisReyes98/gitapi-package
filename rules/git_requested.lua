priority = 1
input_parameter = "request"
events_table = ["git_requested"]

request.method == "GET"
and
#request.path_segments == 1
and
request.path_segments[1] == "git"
