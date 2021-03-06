#!/bin/bash

conf=/data/netxmsd.conf
db_path=/data/Init-DB
log_file=/data/netxms.log
data_directory=/data/netxms
predefined_templates=/data/predefined-templates
debug=2

if [ ! -f "${conf}" ]; then
    echo "Generating NetXMS server config file ${conf}"
    cat > ${conf} <<EOL
DBDriver = mysql.ddr
DBServer = netxms-mysql
DBName = netxms_db
DBLogin = root
DBPassword = tivit123
Logfile=${log_file}
DataDirectory=${data_directory}
DebugLevel = ${debug}
CreateCrashDumps = yes
${SERVER_CONFIG}
EOL
fi

[ ! -d "${data_directory}" ] && cp -ar /var/lib/netxms/ ${data_directory}
[ ! -d "${predefined_templates}" ]  && cp -ar /usr/share/netxms/default-templates/ ${predefined_templates}
[ -f "${db_path}" ] && { echo "Initializing NetXMS database"; nxdbmgr -c ${conf} init /usr/share/netxms/sql/dbinit_mysql.sql; rm -f "${db_path}";  }
[ "${UNLOCK_ON_STARTUP}" -gt 0 ] && { echo "Unlocking database"; echo "Y" | nxdbmgr -c ${conf} unlock; }
[ "${UPGRADE_ON_STARTUP}" -gt 0 ] && { echo "Upgrading database"; nxdbmgr ${UPGRADE_PARAMS} -c ${conf} upgrade; }

# Usage: netxmsd [<options>]
# 
# Valid options are:
#    -e          : Run database check on startup
#    -c <file>   : Set non-default configuration file
#    -d          : Run as daemon/service
#    -D <level>  : Set debug level (valid levels are 0..9)
#    -h          : Display help and exit
#    -p <file>   : Specify pid file.
#    -q          : Disable interactive console
#    -v          : Display version and exit

debug_level=""
if [ "$DEBUG_LEVEL" -gt 0 ]; then
    debug_level="-D ${DEBUG_LEVEL}"
fi

/usr/bin/netxmsd -q ${debug_level} -c ${conf}


