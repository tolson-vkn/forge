#!/bin/bash

for file in $(cat files.txt); do
    front=$(cut -d_ -f1 <<< $file)
    echo mv $file $front
done

