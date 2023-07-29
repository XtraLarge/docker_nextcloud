FROM nextcloud:apache

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        ghostscript \
        libmagickcore-6.q16-6-extra \
        procps \
        smbclient \
        supervisor \
#       libreoffice \
    ; \
    rm -rf /var/lib/apt/lists/*

#RUN set -ex; \
#    savedAptMark="$(apt-mark showmanual)"; 

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libbz2-dev \
        libc-client-dev \
        libkrb5-dev \
        libsmbclient-dev

RUN set -ex; \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    docker-php-ext-install \
        bz2 \
        imap
RUN set -ex; \
    pecl install smbclient; \
    docker-php-ext-enable smbclient; 

# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
#RUN set -ex; \
#    apt-mark auto '.*' > /dev/null; \
#    apt-mark manual $savedAptMark; \
#    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
#        | awk '/=>/ { print $3 }' \
#        | sort -u \
#        | xargs -r dpkg-query -S \
#        | cut -d: -f1 \
#        | sort -u \
#        | xargs -rt apt-mark manual;

#RUN set -ex; \
#    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
#    rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
    /var/log/supervisord \
    /var/run/supervisord 

COPY supervisord.conf /

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
