FROM cgr.dev/chainguard/go:latest AS build
WORKDIR /go
ENV GOBIN=/go/bin
RUN go install tailscale.com/cmd/gitops-pusher@gitops-1.30.0

FROM cgr.dev/chainguard/wolfi-base

COPY --from=build /go/bin/gitops-pusher /usr/local/bin/gitops-pusher
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
