FROM golang:1.21.1 as builder
RUN go install tailscale.com/cmd/derper@main

FROM ghcr.io/tailscale/tailscale:latest
WORKDIR /app
COPY --from=builder /go/bin/derper .
COPY ./entrypoint.sh ./docker-entrypoint.sh
# Fix golang binary runtime error, clean cache and chmod
RUN mkdir /lib64 && ln -s /lib/ld-musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && rm -rf /var/cache/apk/* && rm -rf /root/.cache && rm -rf /tmp/* && chmod +x /app/docker-entrypoint.sh
ENTRYPOINT /app/docker-entrypoint.sh
