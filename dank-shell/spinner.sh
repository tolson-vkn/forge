#!/bin/bash

# Useful to inject in scripts for loading bar things...

while true; do
    for x in '|' '/' '-' '\'; do
        echo -n $x;
        sleep .075;
        echo -e -n '\r';
    done
done
