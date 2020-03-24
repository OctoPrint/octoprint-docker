## get latest stable tag from github foosel/OctoPrint
curl --head --silent --write-out %{redirect_url} --output /dev/null https://github.com/foosel/OctoPrint/releases/latest | awk -F '/' '{print $8}'
