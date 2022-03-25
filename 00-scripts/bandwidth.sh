#!/bin/bash

# Required variables:
#   $ROLE     - can be "server" or "client"; the measurement is performed from the client to the server
#   $SERVER   - for example "10.10.10.12"; server address
#   $CLIENT   - for example "10.10.10.11"; client address

# Optional variables:
#   $INTERVAL - (only if $ROLE="client") for example "120" (by default "60"); number of seconds between checks
#   $PORT     - for example "5686" (by default "9037"); the port on which the server is listening

INTERVAL="${INTERVAL:-60}"
PORT="${PORT:-9037}"
OUTPUT_FILE="/tmp/report.json"

CHECK_NAME="iperf3_bandwidth"
METRICS_PATH="/metrics/index.html"
METRICS_LABELS="sent received"

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
        METRIC_NAME="$(echo $CHECK_NAME{label=$LABEL, client_node=$CLIENT, server_node=$SERVER})"
        METRIC_VALUE=$(cat $OUTPUT_FILE | jq -r .end.sum_$LABEL.bits_per_second)
        log "$METRIC_NAME $METRIC_VALUE"
        grep -w "$METRIC_NAME" $METRICS_PATH > /dev/null
        if [[ $? -eq 0 ]] ; then
            sed -i "s/$METRIC_NAME .*/$METRIC_NAME $METRIC_VALUE/g" $METRICS_PATH
        else
            echo "$METRIC_NAME $METRIC_VALUE" >> $METRICS_PATH
        fi
    done
}

function iperf3_server {
    log "Starting up the iperf3 server on port $PORT"
    iperf3 --server --port $PORT --interval 2 --json &> /dev/null
}

function iperf3_client {
    log "Starting up the iperf3 client to test the speed up to $SERVER:$PORT with interval $INTERVAL"
    echo > $METRICS_PATH
    while true; do
        echo > $OUTPUT_FILE
        iperf3 --client $SERVER --port $PORT --interval 2 --time 6 --json --logfile $OUTPUT_FILE
        exporter
        sleep $INTERVAL;
    done
}

if [ -z "$ROLE" ]; then
    log "Variable \$ROLE is not set"
    exit 1
fi

if [ "$ROLE" = "server" ]; then
    log "Run iperf3 in server mode"
    iperf3_server
elif [ "$ROLE" = "client" ]; then
    log "Run iperf3 in client mode"
    iperf3_client
else
    log "Check the \$ROLE variable. Can only be a \"server\" or a \"client\""
    exit 1
fi
