FROM alpine:3.15.2

ARG USER="app"
ARG GOBEN_VERSION="v0.6"

ENV GOBEN_BIN="/opt/goben"
ENV METRICS_DIR="/opt/exporter"

COPY 00-scripts/bandwidth.sh /opt/bandwidth.sh

RUN apk add --no-cache bash \
    useradd -ms /bin/bash $USER \
    wget https://github.com/udhos/goben/releases/download/$GOBEN_VERSION/goben_linux_amd64 -O $GOBEN_BIN \
    chmod +x $GOBEN_BIN \
    chmod +x /opt/bandwidth.sh \
    mkdir -p $METRICS_DIR

USER $USER

WORKDIR /opt

CMD ["/opt/bandwidth.sh"]