#!/bin/bash

dir="$1"
malicious_dir="$2"
interval="$3"

if [ $# -ne 3 ]; then
    echo " use: $0 <dir> <malicious_dir> <interval_seconds>"
    exit 1
fi

# Scan the directory
scan() {
    for file in "$dir"/*
    do
        if [ -f "$file" ]; then

            malicious=false

            # Check extension
            extension=".${file##*.}"

            case "$extension" in
                .exe|.bat|.vbs|.scr|.ps1)
                    malicious=true
                    ;;
            esac

            # Check content
            if grep -qi "virus" "$file" ||
               grep -qi "trojan" "$file" ||
               grep -qi "malware" "$file" ||
               grep -qi "worm" "$file" ||
               grep -qi "ransomware" "$file"
            then
                malicious=true
            fi

            # Quarantine malicious file
            if [ "$malicious" = true ]; then
                echo "$file is malicious and it is DELETED"
                cp "$file" "$malicious_dir"
                rm "$file"
            fi
        fi
    done
}

# First scan
if [ ! -f "directory-info.last" ]; then
    scan
    ls -l "$dir" > directory-info.last
fi

# Keep checking for changes
while true
do
    sleep "$interval"

    ls -l "$dir" > directory-info.new

    if ! cmp -s directory-info.last directory-info.new
    then
        scan
        cp directory-info.new directory-info.last
    fi
done
