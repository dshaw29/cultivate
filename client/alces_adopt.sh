#!/bin/bash

SERVER_IP="cultivate01"
SERVER_PORT="8080"
ACTION=$1
STATE=$2
HOSTNAME=$(hostname)

CLIENT_DIR="/opt/alces/client"
# Create directory if it doesn't exist
if [ ! -d "$CLIENT_DIR" ]; then
    mkdir -p "$CLIENT_DIR"
fi

STATE_FILE=$CLIENT_DIR/.$ACTION
if [ ! -f "$STATE_FILE" ]; then
    touch "$STATE_FILE"
fi

# Function to display usage information
usage() {
    echo "Usage: alces <action> <state>"
    echo "Actions: alerting, backups, change-control, monitoring, security"
    echo "States: enable, disable, status"
    exit 1
}

# Validate action
validate_action() {
    local action="$1"
    case "$action" in
        alerting|backups|change-control|monitoring|security)
            ;;
        *)
            echo "Invalid action: $action"
            usage
            ;;
    esac
}

validate_action "$ACTION"

# Validate number of arguments
if [[ $# -ne 2 ]]; then
    usage
fi

case $STATE in
    enable|disable)
	#Check if state is different to current state
	CURRENT_STATE=$(cat $STATE_FILE)
        if [ "$CURRENT_STATE" != "$STATE" ]; then #changed - so update state file + continue
	        echo "$STATE" > "$STATE_FILE"
    	else
        	echo "$ACTION is already in the state: $STATE - No action needed"
    	fi
        ;;
   status)
        CURRENT_STATE+=$(cat $STATE_FILE)"d" #Maybe the smartest bash I've ever done?
        echo "$ACTION is currently $CURRENT_STATE"
	;;
    *)
        echo "Invalid state: $STATE"
        usage
        ;;
esac

curl -s "http://$SERVER_IP:$SERVER_PORT/notify?action=$ACTION&state=$STATE&hostname=$HOSTNAME"
