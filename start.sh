#!/bin/bash

# ./start.sh $ROLE $SERVER $CLIENT $PORT $EXPORTER_PORT
#
#  Required variables:
#    $ROLE   - can be "server" or "client"; the measurement is performed from the client to the server
#    $SERVER - for example "10.10.10.12"; server address
#    $CLIENT - for example "10.10.10.11"; client address
#
#  Optional variables:
#    $PORT          - optional, for example "5686" (by default "9037"); the port on which the server is listening
#    $EXPORTER_PORT - optional, for example "9091" (by default "9095"); the port on which the exporter is running (web server)


# for example: ./start.sh server 10.10.10.12 10.10.10.11 5686 9091

ROLE=${1}
SERVER=${2}
CLIENT=${3}
PORT="${4:-9037}"
EXPORTER_PORT="${5:-9095}"

if [[ -z $ROLE || -z $SERVER || -z $CLIENT ]]; then
  echo -e 'One or more variables are undefined. Startup example:\n    ./start.sh $ROLE $SERVER $CLIENT $PORT $EXPORTER_PORT ($PORT and $EXPORTER_PORT- not required)\n or    \n./start.sh server 10.10.10.12 10.10.10.11'
  exit 1
fi

TEMPFILE="$( mktemp )"

mv docker-compose.yaml docker-compose-`date +%Y%m%d`-`date +%H%M%S`.yaml || true

if [ "$ROLE" = "client" ]; then
    echo "Generating a docker-compose.yaml for the $ROLE ..."
    for FILE in $(ls 10-files/*.tpl); do
        echo "collect $FILE ..."
        sed -e 's/$ROLE/'"$ROLE"'/g' -e 's/$SERVER/'"$SERVER"'/g' -e 's/$CLIENT/'"$CLIENT"'/g' -e 's/$PORT/'"$PORT"'/g' -e 's/$EXPORTER_PORT/'"$EXPORTER_PORT"'/g' $FILE >> $TEMPFILE
    done
    sed '/remove for client/d' $TEMPFILE > docker-compose.yaml && rm $TEMPFILE
    echo -e "Done, now you can just: docker-compose up -d"
elif [ "$ROLE" = "server" ]; then
    echo "Generating a docker-compose.yaml for the $ROLE ..."
    sed -e 's/$ROLE/'"$ROLE"'/g' -e 's/$SERVER/'"$SERVER"'/g' -e 's/$CLIENT/'"$CLIENT"'/g' -e 's/$PORT/'"$PORT"'/g' -e 's/$EXPORTER_PORT/'"$EXPORTER_PORT"'/g' 10-files/00-iperf.tpl >> $TEMPFILE
    sed '/remove for server/d' $TEMPFILE > docker-compose.yaml && rm $TEMPFILE
    echo -e "Done, now you can just: docker-compose up -d"
else
    echo "Check the \$ROLE variable. Can only be a \"server\" or a \"client\""
    exit 1
fi