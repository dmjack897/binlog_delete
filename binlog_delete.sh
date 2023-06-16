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
    #삭제대상 출력
    find ${BIN_LOG} -name "mysql-bin.*" -mtime +3  -exec ls -l {} \;

elif [ "${mode}" = "delete" ]; then
    #삭제전,disk사이즈확인
    df_command="df -h"
    eval ${df_command}

    #bin로그 확인
    find ${BIN_LOG} -name "mysql-bin.*" -exec ls -l {} \;

    #MySQL Host확인
    /usr/local/mysql/bin/mysql -u dba -pgnavidba mysql -t -e "select @@hostname"

    #삭제
    /usr/local/mysql/bin/mysql -u dba -pgnavidba mysql -t -e "purge master logs before (now() - interval 3 day);" 

    #삭제후, bin로그확인
　　ls_command="ls -l /db/data/mysql-bin.*"
    eval ${ls_command}

    #삭제후,disk사이즈확인
    eval ${df_command}
fi
echo "END:"`date`
} 2>&1 |
while read line;
do
    echo "${line}" | tee -a ${LOG}
done
    find ${LOG_DIR} -name "*.log" -mtime +7 -exec rm {} \;

