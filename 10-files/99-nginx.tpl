      volumes:
        - static-content:/opt/exporter
    nginx:
      image: nginx:1.17.9
      ports:
        - $SERVER:9095:80
      restart: always
      logging:
        driver: "json-file"
        options:
          max-size: "200m"
          max-file: "16"
      volumes:
        - static-content:/opt/exporter
        - 10-files/nginx.conf:/etc/nginx/nginx.conf
volumes:
  static-content:
