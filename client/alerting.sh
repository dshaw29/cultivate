#!/bin/bash

#Hostname is passed as $1 + 'state' is passed as $2
HOST=$1
STATE=$2

#Probably implement something to work out if this is a state change or not (if not, dont alert/do anything)

case "$STATE" in
    enable)
	#Notify Slack using notify.sh
        bash /opt/cultivate/notify.sh "$HOST" "Alerting to be ENABLED"
	#We should stick clever things here to enable host on zabbix
        ;;
    disable)
	#Notify Slack using notify.sh
        bash /opt/cultivate/notify.sh "$HOST" "Alerting to be DISABLED"
        #We should stick clever things here to disable host on zabbix
        ;;
    status)
        echo "Checking status..."
        # Add additional actions as needed
        ;;
esac

