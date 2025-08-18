FROM nextcloud:apache

RUN apt-get update && apt-get install -y procps smbclient && rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        ghostscript \
        libmagickcore-7.q16-10-extra \
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
        imap \
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
