ARG VERSION

FROM golang:alpine3.20 as build-prerequisites

ARG SHOUT_VERSION=v0.1.1

RUN git clone --branch ${SHOUT_VERSION} --depth=1 --single-branch https://github.com/bacchusjackson/shout /app/shout

RUN cd /app/shout && \
    go build -ldflags="-s -w -X 'main.cliVersion=$(git describe --tags)' -X 'main.gitCommit=$(git rev-parse HEAD)' -X 'main.buildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ)' -X 'main.gitDescription=$(git log -1 --pretty=%B)'" -o /usr/local/bin .

FROM ghcr.io/easy-up/portage:${VERSION}

COPY --from=build-prerequisites /usr/local/bin/shout /usr/local/bin/shout

COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
