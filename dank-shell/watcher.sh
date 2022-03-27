#!/bin/bash
# Monitor for condition, do something
# I first used this when needing a name transfer.

c="dig +short example.com NS"
file=$(mktemp)
$c > $file
while true; do
    diff <($c) $file
    exit=$?
    if [[ "$exit" -ne "0" ]]; then 
        # Gotify
        # curl "https://gotify.example.com/message?token=FJ2jcajfFL2jci3" -F "title=NS change" -F "message=Yeeet" -F "priority=1" 
        # Notty sound
        # ffplay -nodisp -autoexit ~/Music/DSWPNUP.mp3
        echo "Different"
        break
    else
        echo "Same"
    fi
    sleep 5
done

rm $file
