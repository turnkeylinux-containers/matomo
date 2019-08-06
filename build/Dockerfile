FROM 415681119924.dkr.ecr.eu-west-1.amazonaws.com/php-fpm:7.3

ARG PRODUCT_NAME
ARG PRODUCT_VERSION

ENV PRODUCT_NAME="${PRODUCT_NAME}"
ENV PRODUCT_VERSION="${PRODUCT_VERSION}"

LABEL maintainer "TurnKey Linux Containers <aws-containers@turnkeylinux.org>"
LABEL appliance  "${PRODUCT_NAME}"
LABEL version    "${PRODUCT_VERSION}"

ARG APT_CACHER

ARG KEEP_USER
ENV KEEP_USER="${KEEP_USER}"

ENV SRCDIR='/usr/src'
ENV WEBDIR='/var/www/html'

SHELL ["/bin/bash", "-c"]
COPY overlay /

RUN set -exuo pipefail; \
    for conf in /usr/share/tklc/conf/*; do \
        chmod +x "${conf}"; \
        ./"${conf}"; \
    done; \
    rm -rf /var/lib/apt/lists/*

STOPSIGNAL SIGTERM
ENTRYPOINT ["keyhole"]

# rest is provided by per-product Dockerfile
# VOLUME, PORT, CMD etc

EXPOSE 9000
CMD ["php-fpm"]
