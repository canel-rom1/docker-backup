#!/bin/bash
set -e

BKP_CRON_FILE="/tmp/wp-bkp.cron"

trap "echo SIGNAL" HUP INT QUIT KILL TERM

if [ ! -f "${BKP_CRON_FILE}" ]
then
        echo 'MYSQL_HOST=$MYSQL_HOST' >> "${BKP_CRON_FILE}"
        echo 'MYSQL_USER=$MYSQL_USER' >> "${BKP_CRON_FILE}"
        echo 'MYSQL_DATABASE=$MYSQL_DATABASE' >> "${BKP_CRON_FILE}"
        echo 'MYSQL_PASSWORD=$MYSQL_PASSWORD' >> "${BKP_CRON_FILE}"
        echo "SHELL=/bin/bash" >> "${BKP_CRON_FILE}"
        echo 'PATH=$PATH/:usr/local/bin' >> "${BKP_CRON_FILE}"
        #echo "MAILTO=${BACKUP_MAIL}" >> "${BKP_CRON_FILE}"
        echo "${BACKUP_TIME} /usr/local/bin/export.sh >> /tmp/export.log 2>&1" >> "${BKP_CRON_FILE}"
fi

crontab "${BKP_CRON_FILE}"
crontab -l

if [ "$1" = "cron" -a -z "$2" ] ; then
        echo "Run default command: cron -f"
        exec /usr/sbin/cron -f
fi
                       
exec "$@"
