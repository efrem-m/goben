FROM alpine:3.15.2

RUN apk add --no-cache bash iperf3 jq

COPY 00-scripts/bandwidth.sh /opt/bandwidth.sh

WORKDIR /opt

CMD ["/opt/bandwidth.sh"]