#!/bin/bash
docker run --rm \
        --memory=5g \
        --cpus=4 \
        --network=NETWORK \
        -v $(pwd):/local-output \
        -v /home/USER/.gdrive/token_v2.json:/root/.gdrive/token_v2.json \
        canelrom1/docker-backup:latest \
        backup  --dump-mongo \
                --db-host MONGODB \
                --copy-gdrive \
                --gdrive-parentid "XXXXXXXXXX-PARENT-ID-XXXXXXXXXXXX" \
                FILE_NAME
