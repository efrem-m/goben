version: '3.3'
services:
    iperf:
      build: .
      image: iperf:local
      ports:                        # remove for client
        - $SERVER:$PORT:$PORT       # remove for client
      environment:
        ROLE: $ROLE
        SERVER: $SERVER
        CLIENT: $CLIENT
      restart: always
      logging:
        driver: "json-file"
        options:
          max-size: "200m"
          max-file: "16"
