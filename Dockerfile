# Basis-Tag des offiziellen Images: "apache" (neueste Major-Version) oder "<major>-apache" fuer Zwischen-Images
ARG NEXTCLOUD_BASE=apache
FROM nextcloud:${NEXTCLOUD_BASE}

RUN apt-get update && apt-get install -y procps smbclient && rm -rf /var/lib/apt/lists/*

# Name des ImageMagick-Extra-Pakets haengt vom Debian-Release der Basis ab
RUN set -ex; \
    . /etc/os-release; \
    case "$VERSION_CODENAME" in \
        bookworm) MAGICK=libmagickcore-6.q16-6-extra ;; \
        *)        MAGICK=libmagickcore-7.q16-10-extra ;; \
    esac; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        ghostscript \
        "$MAGICK" \
        procps \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    supervisor \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /var/log/supervisord /var/run/supervisord

RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libbz2-dev \
        libsmbclient-dev \
    ; 

RUN set -ex; \
    docker-php-ext-install \
        bz2 \
    ;

RUN set -ex; \
    pecl install smbclient; \
    docker-php-ext-enable smbclient; 

RUN set -ex; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*;

COPY supervisord.conf /

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
