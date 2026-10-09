#!/bin/bash
dir="$1"    
malicious_dir="$2"

# check number of arguments 
if [ $# -ne 2 ]; then
    echo "use: $0 <dir> <dir_malicious>"
    exit 1
fi

# check files in the quarantine directory
if [ -z "$(ls -A "$malicious_dir")" ]; then
    echo "No malicious files to review."
    exit 0

# choose files to review
echo "Select the file you want to review (enter the number):"

while true 
do
    select file in "$malicious_dir"/*
    do
        if [ -n "$file" ]; then
            echo "selected: $file"
            # show options to restore, delete premenantly or leave the file as it is
            echo "Select an option:"
            echo "1. Restore the file"
            echo "2. Delete the file permanently"
            echo "3. Leave the file as it is"
            read option
            case $option in
                1)
                    # restore the file to the original directory
                    if mv "$file" "$dir" ; then
                        echo "File $(basename "$file") restored to $dir"
                    fi
                    break
                    ;;
                2)
                    # delete the file permanently
                    if rm "$file" ; then
                        echo "File $(basename "$file") deleted permanently"
                    fi
                    break
                    ;;
                3)
                    # leave the file as it is 
                    break
                    ;;
                *)
                    echo "Invalid option"
                    ;;
                esac
            else
                echo "Invalid selection"
            if
        done
    done
            
            