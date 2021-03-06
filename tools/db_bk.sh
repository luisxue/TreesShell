#!/bin/bash
# Author:  Luisxue <luisxue@gmail.com>
# BLOG:  https://luisxue.xcodn.com
#
# Notes: TreesShell for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       http://trees.org.cn
#       https://github.com/luisxue/TreesShell

. ../options.conf
. ../include/check_dir.sh

DBname=$1
LogFile=${backup_dir}/db.log
DumpFile=${backup_dir}/DB_${DBname}_$(date +%Y%m%d_%H).sql
NewFile=${backup_dir}/DB_${DBname}_$(date +%Y%m%d_%H).tgz
OldFile=${backup_dir}/DB_${DBname}_$(date +%Y%m%d --date="$expired_days days ago")*.tgz

[ ! -e "${backup_dir}" ] && mkdir -p ${backup_dir}

DB_tmp=`${db_install_dir}/bin/mysql -uroot -p$dbrootpwd -e "show databases\G" | grep $DBname`
[ -z "$DB_tmp" ] && { echo "[$DBname] not exist" >> $LogFile ;  exit 1 ; }

if [ -n "`ls $OldFile 2>/dev/null`" ]; then
  /bin/rm -f $OldFile
  echo "[$OldFile] Delete Old File Success" >> $LogFile
else
  echo "[$OldFile] Delete Old Backup File" >> $LogFile
fi

if [ -e "$NewFile" ]; then
  echo "[$NewFile] The Backup File is exists, Can't Backup" >> $LogFile
else
  ${db_install_dir}/bin/mysqldump -uroot -p$dbrootpwd --databases $DBname > $DumpFile
  cd ${backup_dir}
  tar czf $NewFile ${DumpFile##*/} >> $LogFile 2>&1
  echo "[$NewFile] Backup success ">> $LogFile
  /bin/rm -f $DumpFile
fi
