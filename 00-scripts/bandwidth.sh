#!/bin/bash

# Required variables:
#   ROLE     - can be "server" or "client"; the measurement is performed from the client to the server
#   SERVER   - for example "10.10.10.12"; server address
#   CLIENT   - for example "10.10.10.11"; client address

# Optional variables
#   INTERVAL - (only if ROLE="client") for example "120" (by default "60"); number of seconds between checks

INTERVAL="${INTERVAL:-60}"
GOBEN_OUTPUT_FILE="/tmp/report.txt"
GOBEN_PORT="9045"

METRICS_NAME="goben_speed_test"
METRICS_PATH="$(echo $METRICS_DIR/index.html)"
METRICS_LABELS="reading writing"

function log {
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    message="$1"
    role="$ROLE"
    echo '{}' | \
    jq  --monochrome-output \
        --compact-output \
        --raw-output \
        --arg timestamp "$timestamp" \
        --arg role "$role" \
        --arg message "$message" \
        '.timestamp=$timestamp|.role=$role|.message=$message'
}

function exporter {
    for LABEL in $METRICS_LABELS; do
        CHECK_NAME="$(echo $METRICS_NAME{label=$LABEL, client_node=$CLIENT, server_node=$SERVER})"
        CHECK_RESULT_MB=$(cat $GOBEN_OUTPUT_FILE | grep aggregate | grep $LABEL | awk '{print $5}')
        log "$CHECK_NAME $CHECK_RESULT_MB"
        grep -w "$CHECK_NAME" $METRICS_PATH > /dev/null
        if [[ $? -eq 0 ]] ; then
            sed -i "s/$CHECK_NAME .*/$CHECK_NAME $CHECK_RESULT_MB/g" $METRICS_PATH
        else
            echo "$CHECK_NAME $CHECK_RESULT_MB" >> $METRICS_PATH
        fi
    done
}

function goben_server {
    log "Starting up the goben server on port $GOBEN_PORT"
    $GOBEN_BIN -defaultPort ":$GOBEN_PORT"
}

function goben_client {
    log "Starting up the goben client to test the speed up to $SERVER:$GOBEN_PORT with interval $INTERVAL"
    while true; do
        $GOBEN_BIN -hosts $SERVER:$GOBEN_PORT -ascii=false -tls=false -reportInterval 2s -totalDuration 10s &> $GOBEN_OUTPUT_FILE;
        sleep $INTERVAL;
        exporter
    done
}

if [ -z "$ROLE" ]; then
    log "Variable \$ROLE is not set"
    exit 1
fi

if [ "$ROLE" = "server" ]; then
    log "Run goben in server mode"
    goben_server
elif [ "$ROLE" = "client" ]; then
    log "Run goben in client mode"
    goben_client
else
    e
    log "Check the \$ROLE variable. Can only be a \"server\" or a \"client\""
    exit 1
fi
