#/bin/bash

# File: ./backup_wrapper.sh

# Script to automate DB dump and copy to NFS along with pushing backup
# epoch times to pushgateway

# Script should be run by cron, and mindful CLI users. It's not dangerous, it's shell. :)

# Useful prometheus expr with this data: time() - last_backup_time > 86400 (1 day)

PUSHGATEWAY_HOST=pushgateway.monitoring.svc.example.com
PUSHGATEWAY_PORT=9091
JOB=db-backup

usage() {
    printf "\n%s\n\n" "Usage: $0 [[-t \d+] | [-a]] [-n] | [-h]"

    printf "%s\n\n" "Options:"

    printf "\t%s\n" "-t | --time      : (string) Set the time in the backup file. HHMM" \
                    "-n | --nfs       : (flag) Copy the resulting all-HHMM.sql.gz file to NFS" \
                    "-a | --auto_time : (flag) Automatically compute the time using current" \
                    "                   hour and truncating the minutes, 17:43 is 1700"

    printf "%s\n\n" "Examples"

    printf "\t%s\n" "$0 -t 0600" \
                    ""\
                    "Do a daily backup with a set time, and do not copy to NFS" \
                    "" \
                    "Files on host:" \
                    "  - all-0600.sql.gz" \
                    "  - all-0600.log" \
                    "" \
                    "$0 -n -a" \
                    "" \
                    "Backup local on host with all-HH00.sql.gz file name. Note minutes are trunced" \
                    "because no time is given. Then current date is computed and sent to NFS with" \
                    "name all-YYYmmdd-HHMM.sql.gz" \
                    "" \
                    "Files on host:" \
                    "  - all-0600.sql.gz" \
                    "  - all-0600.log" \
                    "Files on NFS:" \
                    "  - all-20190302-0600.sql.gz"
}

while [ "$1" != "" ]; do
    case $1 in
        -t | --time )      shift
                           time=$1
                           ;;
        -n | --nfs )       nfs=1
                           ;;
        -a | --auto_time ) auto_time=1
                           ;;
        -h | --help )      usage
                           exit
                           ;;
        * )                usage
                           exit 1
    esac
    shift
done

echo "Started backup script - $(date)"

# Don't allow -t and -a
if [[ -n $time && -n $auto_time ]]; then
    echo "Can only select one of -t <var>, -a"
    echo "Look at usage [$0 -h]"
    exit 1
fi

if [[ $auto_time -eq 1 ]]; then
    time=$(date +"%H00")
    echo "Automatic time being used: [$time]"
fi

if [[ -z $time ]]; then
    echo "Time cannot be empty string: [$time]"
    echo "Look at usage [$0 -h]"
    exit 1
elif [[ ! $time =~ ^[0-9]{4}$ ]]; then
    echo "Time must be given in 4 digits: [$time] - HHMM - 0600"
    exit 1
fi

FILE_PREFIX=all-$time
BACKUP_DIR=$HOME/11/backups

LOCAL_BACKFILE=$BACKUP_DIR/$FILE_PREFIX.all.gz
LOGFILE=$BACKUP_DIR/$FILE_PREFIX.log

echo "Performing local backup with pg_dumpall"
echo "Resulting backupfile will be [$LOCAL_BACKFILE]"
echo "PostgreSQL pg_dumpall log will be [$LOGFILE]"

# Perform the local backup. It should be something like this if you need it:
# /usr/pgsql-11/bin/pg_dumpall | gzip > $HOME/11/backups/all-0600.sql.gz 2> $HOME/11/backups/all-0600.log
pg_dumpall | gzip > $LOCAL_BACKFILE 2> $LOGFILE
LOCAL_EXIT=$?

# The exit value of the backup is 0, update our metric in pushgateway
if [[ $LOCAL_EXIT -eq 0 ]]; then
    echo "pg_dumpall exited with value [$LOCAL_EXIT]"

    cat <<EOF | curl -fsSL -XPUT --data-binary @- "http://$PUSHGATEWAY_HOST:$PUSHGATEWAY_PORT/metrics/job/$JOB-local"
# TYPE last_backup_time gauge
last_backup_time $(date +%s)
EOF
    if [[ $? -eq 0 ]]; then
        echo "Local backup prometheus metric updated"
    else 
        echo "Local backup prometheus metric failed to update"
    fi
fi

if [[ $nfs -eq 1 ]]; then
    echo "Copying local backup to NFS"

    DBFILE=all-$(date +"%Y%m%d")-$time.sql.gz

    NFS_BACKFILE=/net/db/$DBFILE

    # Copy to mounted NFS
    echo "Resulting NFS file will be [$NFS_BACKFILE]"

    cp $LOCAL_BACKFILE $NFS_BACKFILE
    NFS_EXIT=$?

    # NFS copy has a good exit. But check the checksum of both files' checksums to ensure
    # that they are the same. Need to awk print the result because a pure md5sum check looks
    # like this:
    # $ md5sum all-20190409-1234.sql.gz
    # 1d361014a6ee5b0d4d2ad39e0906c6f9 all-20190409-1234.sql.gz
    if [[ $NFS_EXIT -eq 0 && "$(md5sum $LOCAL_BACKFILE | awk '{print $1}')" == "$(md5sum $NFS_BACKFILE | awk '{print $1}')" ]]; then
        cat <<EOF | curl -fsSL -XPUT --data-binary @- "http://$PUSHGATEWAY_HOST:$PUSHGATEWAY_PORT/metrics/job/$JOB-local"
# TYPE last_backup_time gauge
last_backup_time $(date +%s)
EOF
        if [[ $? -eq 0 ]]; then
            echo "NFS backup prometheus metric updated"
        else 
            echo "NFS backup prometheus metric failed to update"
        fi
    else
        echo NFS copy was not successful or checksums are not the same
        echo NFS backup prometheus metric was not updated
    fi
fi

echo "Completed backup script - $(date)"



