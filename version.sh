## get latest stable tag from github foosel/OctoPrint
exec curl -s https://api.github.com/repos/foosel/OctoPrint/releases/latest |
	jq '.tag_name' | sed 's/"//g'
