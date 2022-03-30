      volumes:
        - static-content:/metrics
    nginx:
      image: nginx:1.17.9
      ports:
        - $CLIENT:$EXPORTER_PORT:80
      restart: always
      logging:
        driver: "json-file"
        options:
          max-size: "200m"
          max-file: "16"
      volumes:
        - static-content:/metrics
        - ./10-files/nginx.conf:/etc/nginx/nginx.conf
volumes:
  static-content:
