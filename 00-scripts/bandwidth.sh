#!/bin/bash

# Required variables:
#   ROLE     - can be "server" or "client"; the measurement is performed from the client to the server
#   SERVER   - for example "10.10.10.12"; server address
#   CLIENT   - for example "10.10.10.11"; client address

# Optional variables
#   INTERVAL - (only if ROLE="client") for example "120" (by default "60"); number of seconds between checks

INTERVAL="${INTERVAL:-60}"
GOBEN_OUTPUT_FILE="/opt/report.txt"

METRICS_NAME="goben_speed_test"
METRICS_PATH="$(echo $METRICS_DIR/index.html)"
METRICS_LABELS="reading writing"

if [ -z "$ROLE" ]; then
    echo "Variable \$ROLE is not set"
    exit 1
fi

function exporter {
    for LABEL in $METRICS_LABELS; do
        CHECK_NAME="$(echo $METRICS_NAME{label=$LABEL, client_node=$CLIENT, server_node=$SERVER})"
        CHECK_RESULT_MB=$(cat $GOBEN_OUTPUT_FILE | grep aggregate | grep $LABEL | awk '{print $5}')
        grep -w $CHECK_NAME $METRICS_PATH > /dev/null
        if [[ $? -eq 0 ]] ; then
            sed -i "s/$METRICS_NAME .*/$METRICS_NAME $CHECK_RESULT_MB/g" $METRICS_PATH
        else
            echo "$METRICS_NAME $CHECK_RESULT_MB" >> $METRICS_PATH
        fi
    done
}

function goben_server {
    $GOBEN_BIN -defaultPort ":9045"
}

function goben_client {
    while true; do
        $GOBEN_BIN -hosts $SERVER:9045 -ascii=false -tls=false -reportInterval 2s -totalDuration 10s &> $GOBEN_OUTPUT_FILE;
        sleep $INTERVAL;
        exporter
    done
}

if [ "$ROLE" = "server" ]; then
    echo "Run goben in server mode ..."
    goben_server
elif [ "$ROLE" = "client" ]; then
    echo "Run goben in client mode ..."
    goben_client
else
    echo "Check the \$ROLE variable. Can only be a \"server\" or a \"client\""
    exit 1
fi
