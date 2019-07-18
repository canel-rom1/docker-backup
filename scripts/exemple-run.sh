#!/bin/bash
docker run --rm \
        --network=wordpress_lan \
        -v wordpress_t-html:/volume-backup \
        -v $(pwd):/local-output \
        -v /home/romain/.gdrive/token_v2.json:/root/.gdrive/token_v2.json \
        canelrom1/docker-backup:latest \
        backup  -h wordpress_db_1 \
                -d wordpress \
                -u user \
                -p dbpass \
                -g \
                -f "1Y6MlVwuIKT4we-9p_jfNlPB_Lbc1OWDh" \
                tt_bak
#Dossier parentID
#-e 1lSREdmX36Yqh7wBU5fNQWd4ENEHk91Zd \
