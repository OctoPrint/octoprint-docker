#!/bin/bash
set -x
## get latest stable tag
curl -s https://api.github.com/repos/foosel/OctoPrint/releases/latest |
	jq .tag_name
