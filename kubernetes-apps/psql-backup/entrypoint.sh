#!/bin/bash
set -e

if [ "$1" = "backup" ]; then
    # Get current hour, this will be used when we make the file output
    # e.g. $CURRENT_HOUR = 06
    # Results in file: db-back-0600
    if [ -z "$BACKUP_FILE" ]; then
        CURRENT_HOUR="$(date +'%H')"
        BACKUP_FILE="/opt/db-back-${CURRENT_HOUR}00"
    fi

    if [ -z "$DBUSER" ]; then
        DBUSER=postgres
    fi

    if [ -Z "$PGPASSWORD" ]; then
        PGPASSWORD=postgres
    fi

    if [ -Z "$HOST" ]; then
        HOST=localhost
    fi

    if [ -Z "$PORT" ]; then
        PORT=5432
    fi

    COMMAND="pg_dump -h $HOST -p $PORT -U $DBUSER --format=c -f $BACKUP_FILE -d $DATABASE -v"
    echo $COMMAND

    if [ -z "$DATABASE" ]; then
        echo "Check your envar command line parameters..."
        echo "Missing \$DATABASE envar, cannot continue."
        exit 1
    fi

    # Run it!
    exec $COMMAND
else
    exec "$@"
fi
