version: '3.3'
services:
    goben:
      build: .
      image: goben:local
      ports:
        - $SERVER:9045:9045
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
