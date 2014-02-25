#!/bin/bash

#
# Called by the backup.sh script to perform the actual backup
# operation. Customize to your heart's content.
#
# Passing in the option "--dry-run" as the first parameter to 
# this function will cause duplicity to run in dry-run mode.
#
function backupOperation () {
    PARAM_DRY_RUN=$1

    duplicity remove-all-but-n-full 2 --force "sftp://user@host/VirtualBox VMs"
    duplicity --full-if-older-than 1W ${PARAM_DRY_RUN} "~/VirtualBox VMs" "sftp://user@host/VirtualBox VMs"
}

if [ $1 == "set" ]; then
    echo "Exporting extra path."

    export PATH=${HOME}/devtools/homebrew/bin:/usr/local/bin:${HOME}/Library/Python/2.7/bin:${PATH}

    echo "Exporting sftp target."
    export SFTP_TARGET="user@host"

    echo "Exporting passwords."

    export PASSPHRASE=""
    export FTP_PASSWORD=""

    echo "Exporting reporting address."
    
    export MAILTO="report@host"
else
    echo "Unsetting passwords."

    unset FTP_PASSWORD
    unset PASSPHRASE

    echo "Unsetting reporting address."

    unset MAILTO
fi
