#!/bin/bash

# ./start.sh $ROLE $SERVER $CLIENT
#  ROLE   - can be "server" or "client"; the measurement is performed from the client to the server
#  SERVER - for example "10.10.10.12"; server address
#  CLIENT - for example "10.10.10.11"; client address

# for example: ./start.sh server 10.10.10.12 10.10.10.11

ROLE=${1}
SERVER=${2}
CLIENT=${3}

if [[ -z $ROLE || -z $SERVER || -z $CLIENT ]]; then
  echo -e 'One or more variables are undefined. For example:\n\n./start.sh $ROLE $SERVER $CLIENT\n or\n./start.sh server 10.10.10.12 10.10.10.11'
  exit 1
fi

mv docker-compose.yaml docker-compose-`date +%Y%m%d`-`date +%H%M%S`.yaml

if [ "$ROLE" = "server" ]; then
    echo "Generating a docker-compose.yaml for the $ROLE ..."
    for FILE in $(ls 10-files/*.tpl); do
        echo "collect $FILE ..."
        sed -e 's/$ROLE/'"$ROLE"'/g' -e 's/$SERVER/'"$SERVER"'/g' -e 's/$CLIENT/'"$CLIENT"'/g' $FILE >> docker-compose.yaml
    done
    echo -e "Done, now you can just: docker-compose up -d"
elif [ "$ROLE" = "client" ]; then
    echo "Generating a docker-compose.yaml for the $ROLE ..."
    sed -e 's/$ROLE/'"$ROLE"'/g' -e 's/$SERVER/'"$SERVER"'/g' -e 's/$CLIENT/'"$CLIENT"'/g' 10-files/00-goben.tpl >> docker-compose.yaml
    echo -e "Done, now you can just: docker-compose up -d"
else
    echo "Check the \$ROLE variable. Can only be a \"server\" or a \"client\""
    exit 1
fi