#!/bin/bash

confirm() {
    echo "Caution:This will blow away your site."
    # call with a prompt string or use a default
    read -r -p "${1:-Delete all persistent data. Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

clean_up() {
echo "Purging persistant_data folder"
chmod -R 755 persistent_data
rm -rf persistent_data

sh create-folders.sh
echo "Done cleanup"
}

confirm && clean_up
