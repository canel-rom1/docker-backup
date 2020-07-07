#!/bin/bash
docker run --rm \
        --memory=5g \
        --cpus=4 \
        --network=odoo_lan \
        -v $(pwd):/local-output \
        -v odoo_extra-addons:/volume-backup \
        canelrom1/docker-backup:latest \
        backup  --copy-volume \
                --odoo \
                --db-host <CONTAINER WEB> \
                --db-name <NAME> \
                --db-password <PASSWORD> \
                --copy-local \
                odoo11
