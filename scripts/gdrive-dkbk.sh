#!/bin/bash
if [ "$#" -eq 0 ]
then
        docker run -it --rm \
                -v /home/romain/Documents/docker/docker-backup/token_v2.json.bolodrive:/root/.gdrive/token_v2.json \
                canelrom1/docker-backup:latest \
                gdrive help
else
        docker run -it --rm \
                -v /home/romain/Documents/docker/docker-backup/token_v2.json.bolodrive:/root/.gdrive/token_v2.json \
                canelrom1/docker-backup:latest \
                gdrive "$@"
fi
