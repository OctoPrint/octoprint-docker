## get latest stable tag from github foosel/OctoPrint
github_repo=$1
curl --head --silent --write-out %{redirect_url} --output /dev/null https://github.com/$github_repo/releases/latest | awk -F '/' '{print $8}'
