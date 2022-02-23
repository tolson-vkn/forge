#!/usr/bin/env bash

# CONFIG
URL="https://hooks.slack.com/services/..."
echo $URL
exit 1
PAYLOAD='{
  "channel": "#team-sre",
  "username": "Car",
  "text": "",
  "icon_emoji": ":car:"
}'

# PARAMS
if [[ $# -eq 0 ]] ; then
    echo 'Please give a message as first arg'
    exit 0
fi

# CHECK jq installed
exit_with_err() {
  echo >&2 "I require jq but it's not installed. Aborting."; exit 1;
}
command -v jq >/dev/null 2>&1 || { exit_with_err; }
type jq >/dev/null 2>&1       || { exit_with_err; }
hash jq 2>/dev/null           || { exit_with_err; }

#SLACK
body=$(echo $PAYLOAD | jq -c --arg msg "$1" '.text = $msg')
curl -X POST -H "Content-Type: application/json" -d "$body" $URL
