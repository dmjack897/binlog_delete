#!/bin/bash

BIN_LOG="/db/data"
LOG_DIR="${BIN_LOG}/mysql"
LOG="${LOG_DIR}/`basename $0`_`date "+%Y%m%d"`.log"

if [ $# -ne 1 ]; then
    echo "[ exec_mode(dry_run/delete) ]"
    exit 1
fi

exec_mode() {
    while getopts ":ld" opts; do
        case ${opts} in
        "l")
        mode="dry_run"
        ;;
        "d")
        mode="delete"
        ;;
        esac
    done
}
{
exec_mode $@
echo "START:"`date`
if [ "${mode}" = "dry_run" ]; then
    #削除対象出力
    find ${BIN_LOG} -name "mysql-bin.*" -mtime +3  -exec ls -l {} \;

elif [ "${mode}" = "delete" ]; then
    #削除前、ディスクの空きサイズ確認
    df_command="df -h"
    eval ${df_command}

    #binログ確認
    find ${BIN_LOG} -name "mysql-bin.*" -exec ls -l {} \;

    #接続MySQL確認
    /usr/local/mysql/bin/mysql -u dba -pgnavidba mysql -t -e "select @@hostname"

    #削除
    /usr/local/mysql/bin/mysql -u dba -pgnavidba mysql -t -e "purge master logs before (now() - interval 3 day);" 

    #削除後、binログ状況
　　ls_command="ls -l /db/data/mysql-bin.*"
    eval ${ls_command}

    #削除後、ディスクの空きサイズ確認
    eval ${df_command}
fi
echo "END:"`date`
} 2>&1 |
while read line;
do
    echo "${line}" | tee -a ${LOG}
done
    find ${LOG_DIR} -name "*.log" -mtime +7 -exec rm {} \;

