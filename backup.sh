#!/bin/bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd "$SCRIPT_PATH/backup" || exit 1
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
mkdir "$DATE"
cd "$DATE" || exit 1

lftp sftp://192.168.1.6:/data -e "mirror; bye"
