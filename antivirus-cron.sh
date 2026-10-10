#!/bin/bash

dir="$1"
malicious_dir="$2"

# Check number of arguments
if [ "$#" -ne 2 ]; then
    echo "Use: $0 <dir> <malicious_dir>"
    exit 1
fi

# Check if the directory exists
if [ ! -d "$dir" ]; then
    echo "Error: Directory to scan does not exist."
    exit 1
fi

# Create quarantine directory if it does not exist
mkdir -p "$malicious_dir" || exit 1

# Scan the directory
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

        # Move malicious files to quarantine
        if [ "$malicious" = true ]; then
            filename="${file##*/}"

            if cp -- "$file" "$malicious_dir/$filename"; then
                if rm -- "$file"; then
                    echo "$(date '+%Y-%m-%d %H:%M:%S') - Quarantined: $filename"
                else
                    echo "Error: Could not remove $filename from source directory."
                fi
            else
                echo "Error: Could not copy $filename to quarantine."
            fi
        fi
    fi
done