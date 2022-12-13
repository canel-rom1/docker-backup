#!/bin/bash
docker run --rm \
        --memory=5g \
        --cpus=4 \
        -v /home/romain/.config/rclone/rclone.conf:/root/.config/rclone/rclone:ro \
        -v myvol:/volume-backup \
        canelrom1/docker-backup:latest \
        backup  --copy-volume \
                -r "bolo:/" \
                test-infra
