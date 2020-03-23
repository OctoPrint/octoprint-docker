#!/bin/bash
set -x
## get latest stable tag from github foosel/OctoPrint
curl -s https://api.github.com/repos/foosel/OctoPrint/releases/latest |
	jq .tag_name
