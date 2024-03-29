#!/bin/bash
set -e

TMP_DIR="/tmp"
VOLUME_BACKUP_DIR="/volume-backup"
LOCAL_OUTPUT_DIR="/local-output"

echo "Welcome to WordPress Backup & Restore"
usage()
{
cat << EOF
Usage: $(basename $0)
EOF
}

# Select arguments
echo "entrée: $@"
script_cmd=${1}
shift
echo "Debug: Command = ${script_cmd} ; argument = $@"

while [ '-' == "${1:0:1}" ]
do
        case "${1}" in
                -c|--first-copy)
                        FIRST_COPY=1
                        ;;
                -d|--db-name)
                        shift
                        arg_name="${1}"
                        if [ "${arg_name:0:1}" = '-' ]
                        then
                                echo "Error: No database name"
                                usage
                                exit 1
                        fi

                        DB_NAME="${arg_name}"
                        ;;
                -e|--gdrive-parentid)
                        shift
                        arg_pid="${1}"
                        if [ "${arg_pid:0:1}" = '-' ]
                        then
                                echo "Error: No Google Drive parentID"
                                usage
                                exit 1
                        fi

                        DRIVE_PARENTID="${arg_pid}"
                        ;;
                -f|--gdrive-fileid)
                        shift
                        arg_fid="${1}"
                        if [ "${arg_fid:0:1}" = '-' ]
                        then
                                echo "Error: No Google Drive fileID"
                                usage
                                exit 1
                        fi

                        DRIVE_FILEID="${arg_fid}"
                        ;;
                -g|--copy-gdrive)
                        echo "Debug: Goggle drive with gdrive"
                        GDRIVE_OUPUT=1
                        ;;
                -h|--db-host)
                        shift
                        arg_host="${1}"
                        if [ ${arg_host:0:1} = '-' ]
                        then
                                echo "Error: No host"
                                usage
                                exit 1
                        fi

                        DB_HOST=${arg_host}
                        ;;
                -l|--copy-local)
                        LOCAL_OUTPUT=1
                        ;;
                -m|--dump-mysql)
                        DUMP_MYSQL=1
                        ;;
                -o|--dump-mongo)
                        DUMP_MONGO=1
                        ;;
                -O|--odoo)
                        SCRIPT_ODOO=1
                        ;;
                -p|--db-password)
                        shift
                        arg_pwd="${1}"
                        if [ -z ${arg_pwd} ]
                        then
                                echo "Error: No password"
                                usage
                                exit 1
                        fi

                        DB_PASSWORD=${arg_pwd}
                        ;;
                -r|--rclone)
                        shift
                        arg_rr="${1}"
                        if [ "${arg_rr:0:1}" = '-' ]
                        then
                                echo "Error: No rclone remote"
                                usage
                                exit 1
                        fi

                        RCLONE_REMOTE="${arg_rr}"
                        echo "Debug: Goggle drive with rclone"
                        ;;
                -u|--db-user)
                        shift
                        arg_user="${1}"
                        if [ -z ${arg_user} ]
                        then
                                echo "Error: No user"
                                usage
                                exit 1
                        fi

                        DB_USER=${arg_user}
                        ;;
                -v|--copy-volume)
                        COPY_VOLUME=1
                        ;;
                "")
                        ;;
                *)
                        echo "Error: Bad argument [${1}] for ${script_cmd} command"
                        usage
                        exit 1
                        ;;
        esac        
        shift
done

if [ -z "${1}" ]
then
        echo "Missing Argument: backup name"
        usage
        exit 1
fi
BAK_NAME="${1}"
INPUT_TAR="${TMP_DIR}/input_tar"
[ -d "${INPUT_TAR}" ] || mkdir "${INPUT_TAR}"
SQL_BAK_FILE="${INPUT_TAR}/${BAK_NAME}-db.$(date +%Y%m%d-%H%M%S).sql"
MDB_BAK_DIR="${INPUT_TAR}/${BAK_NAME}-db-$(date +%Y%m%d-%H%M%S)"
ODOO_BAK_ZIP="${INPUT_TAR}/${BAK_NAME}-db-$(date +%Y%m%d-%H%M%S).zip"
VOL_BAK_TAR="${INPUT_TAR}/${BAK_NAME}-vols.$(date +%Y%m%d-%H%M%S).tgz"
ALL_BAK_TAR="${TMP_DIR}/${BAK_NAME}.tar"

if [ -n "${DUMP_MYSQL}" -a -z "${DB_HOST}" ]
then
        echo "Error: DB_HOST variable not set"
        usage
        exit 1
fi
echo "Debug: host = ${DB_HOST}"

if [ -n "${DUMP_MYSQL}" -a -z "${DB_USER}" ]
then
        echo "Error: DB_USER variable not set"
        usage
        exit 1
fi
echo "Debug: user = ${DB_USER}"

if [ -n "${DUMP_MYSQL}" -a -z "${DB_NAME}" ]
then
        echo "Error: DB_NAME variable not set"
        usage
        exit 1
fi
echo "Debug: database = ${DB_NAME}"

if [ -n "${DUMP_MYSQL}" -a -z "${DB_PASSWORD}" ]
then
        echo "Error: DB_PASSWORD variable not set"
        usage
        exit 1
fi
echo "Debug: password = ${DB_PASSWORD}"

# Main
case ${script_cmd} in
        backup)
                echo "Start Backup"

                if [ -n "${DUMP_MYSQL}" ]
                then
                        echo "Dump MySQL "
                        mysqldump -h"${DB_HOST}" -u"${DB_USER}" --password="${DB_PASSWORD}" "${DB_NAME}" > "${SQL_BAK_FILE}"

                        if [ $? -ne 0 ]
                        then
                                echo "Error: Can't dump database"
                                exit 1
                        fi
                fi

                if [ -n "${DUMP_MONGO}" ]
                then
                        echo "Dump MongoDB"
                        mongodump -h "${DB_HOST}" -o "${MDB_BAK_DIR}"
                fi

                if [ -n "${SCRIPT_ODOO}" ]
                then
                        echo "Backup DB and filestore for Odoo"
                        curl -X POST \
                                -F "master_pwd=${DB_PASSWORD}" \
                                -F "name=${DB_NAME}" \
                                -F "backup_format=zip" \
                                -o ${ODOO_BAK_ZIP} \
                                http://${DB_HOST}:8069/web/database/backup
                fi

                if [ -n "${COPY_VOLUME}" ]
                then
                        if [ -n "${FIRST_COPY}" ]
                        then
                                INTERMEDIATE_DIR="${TMP_DIR}/intermediate_dir"
                                echo "Backup volume content with an intermediate copy"

                                cp -a "${VOLUME_BACKUP_DIR}" "${INTERMEDIATE_DIR}"
                                cd "${INTERMEDIATE_DIR}"
                                tar -pczf "${VOL_BAK_TAR}" .
                                cd - > /dev/null
                        else
                                echo "Backup volume content"
                                cd "${VOLUME_BACKUP_DIR}"
                                tar -pczf "${VOL_BAK_TAR}" .
                                cd - > /dev/null
                        fi
                fi

                echo "Create archive"
                cd "${INPUT_TAR}"
                tar -cf "${ALL_BAK_TAR}" *
                cd - > /dev/null

                if [ -n "${LOCAL_OUTPUT}" ]
                then
                        echo "Copy backup on host"
                        cp "${ALL_BAK_TAR}" "${LOCAL_OUTPUT_DIR}"
                fi

                if [ -n "${GDRIVE_OUPUT}" ]
                then
                        echo "Copy backup on Google Drive with gdrive"
                        if [ -n "${DRIVE_PARENTID}" ]
                        then
                                gdrive upload --no-progress --parent "${DRIVE_PARENTID}" "${ALL_BAK_TAR}"
                        elif [ -n "${DRIVE_FILEID}" ]
                        then
                                gdrive update --no-progress ${DRIVE_FILEID} ${ALL_BAK_TAR}
                        else
                                echo "Error: Google Drive missing arguments"
                        fi
                fi

                if [ -n "${RCLONE_REMOTE}" ]
                then
                        echo "Copy backup on Google Drive with rclone"
                        rclone copy "${ALL_BAK_TAR}" "${RCLONE_REMOTE}"
                fi

                echo "Clean archive"
                rm -f "${SQL_BAK_FILE}" "${VOL_BAK_TAR}" "${ALL_BAK_TAR}"
                ;;
        help)
                usage
                exit 0
                ;;
        *)
                echo "Error: Bad command"
                usage
                exit 1
                ;;
esac
