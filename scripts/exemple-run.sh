#!/bin/bash
docker run --rm \
        --memory=5g \
        --cpus=4 \
        --network=wordpress_lan \
        -v wordpress_t-html:/volume-backup \
        -v $(pwd):/local-output \
        canelrom1/docker-backup:latest \
        backup  --dump-mysql \
                --db-host wordpress_db_1 \
                --db-name wordpress \
                --db-user user \
                --db-password dbpass \
                --copy-local \
                tt_bak
#docker run --rm \
#        --memory=5g \
#        --cpus=4 \
#        --network=wordpress_lan \
#        -v wordpress_t-html:/volume-backup \
#        -v $(pwd):/local-output \
#        -v /home/romain/.gdrive/token_v2.json:/root/.gdrive/token_v2.json \
#        canelrom1/docker-backup:latest \
#        backup  --copy-volume \
#                --dump-mysql \
#                --db-host wordpress_db_1 \
#                --db-name wordpress \
#                --db-user user \
#                --db-password dbpass \
#                --copy-gdrive \
#                --gdrive-fileid "1Y6MlVwuIKT4we-9p_jfNlPB_Lbc1OWDh" \
#                tt_bak
