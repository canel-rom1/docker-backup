#!/bin/bash

TOKEN_FILE="${1:-token_v2.json}"

docker cp "${TOKEN_FILE}" wordpress-backup:/root/.gdrive/token_v2.json
