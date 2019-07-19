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
                -d|--db-name)
                        shift
                        arg_name="${1}"
                        if [ "${arg_name:0:1}" = '-' ]
                        then
                                echo "Error: No database name"
                                usage
                                exit 1
                        fi

                        MYSQL_DATABASE="${arg_name}"
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
                        echo "Debug: Goggle drive"
                        DRIVE_OUTPUT=1
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

                        MYSQL_HOST=${arg_host}
                        ;;
                -l|--copy-local)
                        LOCAL_OUTPUT=1
                        ;;
                -m|--dump-mysql)
                        DUMP_MYSQL=1
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

                        MYSQL_PASSWORD=${arg_pwd}
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

                        MYSQL_USER=${arg_user}
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
VOL_BAK_TAR="${INPUT_TAR}/${BAK_NAME}-vols.$(date +%Y%m%d-%H%M%S).tgz"
ALL_BAK_TAR="${TMP_DIR}/${BAK_NAME}.tar"

if [ -n "${DUMP_MYSQL}" -a -z "${MYSQL_HOST}" ]
then
        echo "Error: MYSQL_HOST variable not set"
        usage
        exit 1
fi
echo "Debug: host = ${MYSQL_HOST}"

if [ -n "${DUMP_MYSQL}" -a -z "${MYSQL_USER}" ]
then
        echo "Error: MYSQL_USER variable not set"
        usage
        exit 1
fi
echo "Debug: user = ${MYSQL_USER}"

if [ -n "${DUMP_MYSQL}" -a -z "${MYSQL_DATABASE}" ]
then
        echo "Error: MYSQL_DATABASE variable not set"
        usage
        exit 1
fi
echo "Debug: database = ${MYSQL_DATABASE}"

if [ -n "${DUMP_MYSQL}" -a -z "${MYSQL_PASSWORD}" ]
then
        echo "Error: MYSQL_PASSWORD variable not set"
        usage
        exit 1
fi
echo "Debug: password = ${MYSQL_PASSWORD}"

# Main
case ${script_cmd} in
        backup)
                echo "Start Backup"

                if [ -n "${DUMP_MYSQL}" ]
                then
                        echo "Dump database"
                        mysqldump -h"${MYSQL_HOST}" -u"${MYSQL_USER}" --password="${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" > "${SQL_BAK_FILE}"

                        if [ $? -ne 0 ]
                        then
                                echo "Error: Can't dump database"
                                exit 1
                        fi
                        SQL_BAK="${SQL_BAK_FILE}"
                fi

                if [ -n "${COPY_VOLUME}" ]
                then
                        echo "Backup volume content"
                        cd "${VOLUME_BACKUP_DIR}"
                        tar -czf "${VOL_BAK_TAR}" *
                        cd - > /dev/null
                        VOL_BAK="${VOL_BAK_FILE}"
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

                if [ -n "${DRIVE_OUTPUT}" ]
                then
                        echo "Copy backup on Google Drive"
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
