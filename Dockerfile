###################
### Base Image  ###
###################
FROM golang:1.12-alpine as baseimage

# Install OS-level dependencies
RUN apk add --no-cache --virtual .build-deps make git bash jq curl

# go build env
ENV CGO_ENABLED=0

WORKDIR /go/src/github.com/tapjoy/sqltocsv

ENTRYPOINT [ "deploy/docker-entrypoint.sh" ]
