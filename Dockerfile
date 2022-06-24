# Dockerfile for https://github.com/adnanh/webhook
FROM        golang:alpine3.11 AS build
WORKDIR     /go/src/github.com/adnanh/webhook
ENV         WEBHOOK_VERSION 2.8.0
ENV         COMPOSE_VERSION v2.6.1
RUN         apk add --update -t build-deps curl libc-dev gcc libgcc
RUN         curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
            curl -L --silent -o /tmp/docker-compose https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) && \
            tar -xzf webhook.tar.gz --strip 1 &&  \
            go get -d && \
            go build -o /usr/local/bin/webhook && \
            apk del --purge build-deps && \
            rm -rf /var/cache/apk/* && \
            rm -rf /go

FROM        alpine:3.11
COPY        --from=build /tmp/docker-compose /usr/local/bin/docker-compose
COPY        --from=build /usr/local/bin/webhook /usr/local/bin/webhook
WORKDIR     /etc/webhook
RUN         apk add openssh docker-cli jq && \
            chmod +x /usr/local/bin/docker-compose && \
            rm -rf /var/cache/apk/*
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
