#!/bin/bash

verbose=0
recursive=0
uncompressed_files=0
successful_unpack=false

is_successful_unzip(){
    if [ $1 -eq 0 ]; then
        if [ "$verbose" -eq 1 ]; then
            echo "Unpacking $(basename "$2"...)"
        fi
        uncompressed_files=$((uncompressed_files + 1))
    elif [ "$verbose" -eq 1 ]; then
        echo "Ignoring $(basename "2")"
    fi
}

for item in "$@"; do
    if [[ -d "$item" ]]; then

        if [[ $recursive -eq 1 ]]; then
            for file in *; do
                "$0" "$file"  # Call the script recursively for each file
            done
        fi
        
        for file in "$item"/*; do
            case ${file} in
            -v)
                verbose=1
                ;;
            -r)
                recursive=1
                ;;
            *.gz*)
                gunzip -f -q "$file" 
                is_successful_unzip $? "$file" 
                successful_unpack=true
                ;;
            *.bz2*)
                bunzip2 -f -q "$file"
                is_successful_unzip $? "$file"
                successful_unpack=true
                ;;
            *.zip*)
                unzip -o -q "$file" -d "$(dirname "$file")" && rm -f "$file"
                is_successful_unzip $? "$file"
                successful_unpack=true
                ;;
            *.Z*)
                uncompress -q "$file"
                is_successful_unzip $? "$file" 
                successful_unpack=true
                ;;
            *.cmpr*)
                mv "$file" "${file%.cmpr}.gz"   
                gunzip -f -q "${file%.cmpr}.gz"  
                is_successful_unzip $? "$file"
                successful_unpack=true
                ;;
            *)
                ;;
    esac
        done
    fi

    case ${item} in
            -v)
                verbose=1
                ;;
            -r)
                recursive=1
                ;;
            *.gz*)
                gunzip -f -q "$item"
                is_successful_unzip $? "$item" 
                successful_unpack=true
                ;;
            *.bz2*)
                bunzip2 -f -q "$item"
                is_successful_unzip $? "$item"
                successful_unpack=true
                ;;
            *.zip*)
                unzip -o -q "$item" 
                is_successful_unzip $? "$item" && rm -f "$item"
                successful_unpack=true
                ;;
            *.Z*)
                uncompress -q "$item"
                is_successful_unzip $? "$item" 
                successful_unpack=true
                ;;
            *.cmpr*)
                mv "$item" "${item%.cmpr}.gz"   
                gunzip -f -q "${item%.cmpr}.gz"  
                is_successful_unzip $? "$item"
                successful_unpack=true
                ;;
            *)
                ;;
    esac
done

if [[ "$successful_unpack" == false ]]; then
    exit 1
else
    echo "Decompressed $uncompressed_files archive(s)"
    exit 0
fi