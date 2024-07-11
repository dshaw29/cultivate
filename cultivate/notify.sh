#!/bin/bash

#Script to ping Slack when a request to update state of something is made

HOST=$1
CHANGE=$2
source /opt/cultivate/config_global

function slack {
cat <<EOF | curl -k --silent --output /dev/null --data @- -X POST -H "Authorization: Bearer $SLACK_TOKEN" -H 'Content-Type: application/json' https://slack.com/api/chat.postMessage
{
  "text": "$msg",
  "channel": "$channel",
  "as_user": true
}
EOF
}

# Basic script, ping slack on reboot
channel="channel_name"
msg="
Change requested on: $(date) \n
\`$HOST\` - Has requested $CHANGE
"

slack
