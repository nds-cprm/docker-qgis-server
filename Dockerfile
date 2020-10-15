FROM debian:buster-slim

ENV LANG=en_US.UTF-8



RUN set -ex ; \
    apt-get update ; \
    apt-get install --no-install-recommends --no-install-suggests --allow-unauthenticated -y \
        gnupg \
        ca-certificates \
        wget \
        locales ; \
    localedef -i en_US -f UTF-8 en_US.UTF-8 ; \
    wget -O - https://qgis.org/downloads/qgis-2020.gpg.key | gpg --import ; \
    gpg --export --armor F7E06F06199EF2F2 | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import ; \
    chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg ; \
    echo "deb http://qgis.org/debian-ltr buster main" >> /etc/apt/sources.list.d/qgis.list ; \
    apt-get update ; \
    apt-get install --no-install-recommends --no-install-suggests --allow-unauthenticated -y \
        qgis-server \
        spawn-fcgi \
        xauth \
        xvfb ; \
    apt-get remove --purge -y \
        gnupg \
        wget ; \
    rm -rf /var/lib/apt/lists/*

RUN set -ex ; \
    groupadd -g 200 qgis ; \
    useradd -g 200 -u 200 -m qgis ; \
    mkdir -p /var/lib/qgis/data ; \
    chown qgis:qgis /var/lib/qgis/data

ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENV QGIS_PREFIX_PATH /usr
ENV QGIS_SERVER_LOG_STDERR 1
ENV QGIS_SERVER_LOG_LEVEL 2

COPY cmd.sh /var/lib/qgis/cmd.sh
RUN chown qgis:qgis /var/lib/qgis/cmd.sh

USER qgis
WORKDIR /var/lib/qgis

ENTRYPOINT ["/tini", "--"]

CMD ["./cmd.sh"]