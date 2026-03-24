ARG VERSION=latest

FROM ghcr.io/easy-up/portage:${VERSION}

COPY entrypoint.sh /entrypoint.sh

# GitHub actions containers must run as root
USER root

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
