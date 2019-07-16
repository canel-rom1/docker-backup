#!/bin/bash
set -e
set -x

TMP_DIR="/tmp"
SQL_BAK_FILE="${TMP_DIR}/wp-db.sql"
WP_BAK_TAR="${TMP_DIR}/wp-site.tgz"
ALL_BAK_TAR="${TMP_DIR}/wp-site-db.tar"
WP_HTML_CONTENT_DIR="/wp-site-html"
GD_BAK_DIR="backup-wp"

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

usage()
{
        echo "Usage: $(basename $0)"
        echo "No arguments"
        exit 1
}

#Command for gdrive
gd_del()
{
        file="$1"
        echo "Debug: gd_del()"
        [ -z "${file}" ] && echo "Error: Missing argument in $0" && exit 1
        gdrive delete $(gdrive list|grep ${file}|awk '{print $1}')
}
gd_upload()
{
        file="$1"
        dir="$2"

        echo "Debug: gd_upload()"

        [ -z "${file}" ] && echo "Error: Missing argument in $0" && exit 1
        if [ -n "${dir}" ]
        then
                echo "Debug: Add file in directory: ${dir}"
                parent="-p $(gdrive list|grep ${dir}|awk '{print $1}')"
        fi

        gdrive upload --no-progress ${parent} ${file}
}
gd_update()
{
        file="$1"

        echo "Debug: gd_update()"

        [ -z "${file}" ] && echo "Error: Missing argument in $0" && exit 1
        gdrive update $(gdrive list|grep $(basename ${file})|awk '{print $1}') ${file}
}

echo "Backup Wordpress website"

if [ -z "${MYSQL_HOST}" ]
then
        echo "MYSQL_HOST variable not set"
        exit 1
fi
echo "host:${MYSQL_HOST}"

if [ -z "${MYSQL_USER}" ]
then
        echo "MYSQL_USER variable not set"
        exit 1
fi
echo "user:${MYSQL_USER}"

if [ -z "${MYSQL_PASSWORD}" ]
then
        echo "MYSQL_PASSWORD variable not set"
        exit 1
fi
echo "password:${MYSQL_PASSWORD}"

if [ -z "${MYSQL_DATABASE}" ]
then
        echo "MYSQL_DATABASE variable not set"
        exit 1
fi
echo "db:${MYSQL_DATABASE}"

echo "--Dump database"
mysqldump -h"${MYSQL_HOST}" -u"${MYSQL_USER}" --password="${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" > "${SQL_BAK_FILE}"

if [ $? -ne 0 ]
then
        echo "Error: Can't dump database"
        exit 1
fi


echo "--Backup HTML content"
cd "${WP_HTML_CONTENT_DIR}"
tar -czf "${WP_BAK_TAR}" *
cd -

echo "--Create archive"
cd "${TMP_DIR}"
tar -cf $(basename "${ALL_BAK_TAR}") $(basename "${WP_BAK_TAR}") $(basename "${SQL_BAK_FILE}")
cd -

echo "--Send archive"
gdrive list | grep -q "${GD_BAK_DIR}"
if [ $? -ne 0 ]
then
        gdrive mkdir "${GD_BAK_DIR}"
fi
gdrive list | grep -q $(basename "${ALL_BAK_TAR}")
if [ $? -ne 0 ]
then
        gd_upload "${ALL_BAK_TAR}" "${GD_BAK_DIR}"
else
        gd_update "${ALL_BAK_TAR}"
fi

echo "--Clean"
rm -f "${SQL_BAK_FILE}" "${WP_BAK_TAR}" "${ALL_BAK_TAR}"
