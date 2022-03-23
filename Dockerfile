FROM alpine:3.15.2

ARG GOBEN_VERSION="v0.6"

ENV GOBEN_BIN="/opt/goben"
ENV METRICS_DIR="/opt/exporter"

RUN apk add --no-cache bash && \
    wget https://github.com/udhos/goben/releases/download/$GOBEN_VERSION/goben_linux_amd64 -O $GOBEN_BIN && \
    chmod +x $GOBEN_BIN && \
    mkdir -p $METRICS_DIR

COPY 00-scripts/bandwidth.sh /opt/bandwidth.sh

WORKDIR /opt

CMD ["/opt/bandwidth.sh"]