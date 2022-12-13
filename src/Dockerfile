FROM debian:latest

LABEL maintainer="Rom1 <rom1@canel.ch> - CANEL - https://www.canel.ch"
LABEL date="16/07/2019"
LABEL description="Backup for WordPress"

RUN apt-get update \
 && apt-get -y -q --no-install-recommends \
            install \
                    apt-transport-https \
                    ca-certificates \
                    curl \
                    dirmngr \
                    gnupg \
                    mariadb-client \
                    rclone \
                    software-properties-common \
                    wget \
 &&                 wget -O- https://www.mongodb.org/static/pgp/server-5.0.asc \
                      | gpg --dearmor \
                      > /usr/share/keyrings/mongodb.gpg \
 &&                 echo 'deb [signed-by=/usr/share/keyrings/mongodb.gpg] http://repo.mongodb.org/apt/debian buster/mongodb-org/5.0 main' \
                    > /etc/apt/sources.list.d/mongodb-org-5.0.list \
 && apt-get update \
 && apt-get install -y -q --no-install-recommends mongodb-org-tools \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
# && rm -rf /var/lib/apt/lists/* \
# &&  wget -O /usr/local/bin/gdrive https://drive.google.com/uc\?id\=1Ej8VgsW5RgK66Btb9p74tSdHMH3p4UNb \
# && chmod +x /usr/local/bin/gdrive

COPY ./bin/gdrive /usr/local/bin/gdrive
RUN chmod +x /usr/local/bin/gdrive

RUN mkdir /volume-backup /root/.gdrive

COPY ./scripts/dkbk.sh /usr/local/bin/dkbk
#COPY ./scripts/connect-gdrive.sh /usr/local/bin/connect-gdrive.sh
RUN chmod +x /usr/local/bin/dkbk

ENV BACKUP_MAIL root

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["backup"]
