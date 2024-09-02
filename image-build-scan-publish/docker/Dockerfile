ARG VERSION

FROM ghcr.io/easy-up/portage:${VERSION}

COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
