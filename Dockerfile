FROM        golang:alpine AS build
WORKDIR     /go/src/github.com/adnanh/webhook
ENV         WEBHOOK_VERSION 2.8.2
RUN         apk add --update -t build-deps curl libc-dev gcc libgcc
RUN         curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
            tar -xzf webhook.tar.gz --strip 1
RUN         go get -d -v
RUN         CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/webhook


FROM alpine:latest AS builder

RUN apk update

RUN apk add --no-cache \
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libssl3 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs \
    curl && \
    apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust  \
    openssh-client \	
	&& curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.5.1/powershell-7.5.1-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz && \
	mkdir -p /opt/microsoft/powershell/7 && \
	tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 && \
	chmod +x /opt/microsoft/powershell/7/pwsh && \
	ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh




FROM        alpine:3.11
COPY        --from=build /usr/local/bin/webhook /usr/local/bin/webhook
WORKDIR     /etc/webhook
RUN         apk add openssh icu-libs libstdc++ docker-cli jq sshpass curl && \
            rm -rf /var/cache/apk/*
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
COPY --from=builder /opt /opt
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
