FROM debian:latest

LABEL maintainer="Rom1 <rom1@canel.ch> - CANEL - https://www.canel.ch"
LABEL date="27/05/2019"
LABEL description="Backup for WordPress"

RUN apt-get update \
 && apt-get -y -q --no-install-recommends \
            install ca-certificates \
                    cron \
                    mysql-client \
                    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 &&  wget -O /usr/local/bin/gdrive https://drive.google.com/uc\?id\=1Ej8VgsW5RgK66Btb9p74tSdHMH3p4UNb \
 && chmod +x /usr/local/bin/gdrive

RUN mkdir /wp-site-html /root/.gdrive

COPY ./scripts/export.sh /usr/local/bin/export.sh
COPY ./scripts/connect-gdrive.sh /usr/local/bin/connect-gdrive.sh

ENV BACKUP_TIME 0 3 * * *
ENV BACKUP_MAIL root

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["cron", "-f"]
