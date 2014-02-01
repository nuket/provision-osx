#!/bin/bash

#
# Usage: 
# 
# backup.sh [-d] [-f]
#
#     -d    Dry run
#     -f    Force full backup
#

# Read in passwords and other settings from separate, non-checked-in file.
#
# It needs to provide the following environment variables:
#
# PASSPHRASE
# FTP_PASSWORD
# MAILTO
#
# And a function called backupOperation() which gets called to do the
# actual backup process.

source backup-settings.sh set

DRY_RUN=0

PARAM_DRY_RUN=""
PARAM_BACKUP_TYPE="" # By default, Duplicity will try to do incremental backups, if a full backup already exists.

MACHINES=$(vboxmanage list runningvms | cut -f 2 -d \")

while getopts ":d" opt; do
    case $opt in
	d)
	    echo "Dry run."
	    DRY_RUN=1
	    PARAM_DRY_RUN="--dry-run"
	    ;;
	f)
	    echo "Full backup."
	    PARAM_BACKUP_TYPE="full"
	    ;;
    esac
done

# See: http://www.pclinuxos.com/forum/index.php?topic=103651.0

function wait_for_closing_machines() {
    echo "Wait for machines to be stopped."

    RUNNING_MACHINES=$(vboxmanage list runningvms | wc -l)

    if [ $RUNNING_MACHINES != 0 ]; then
	echo "Waiting for VM shutdown to complete."
	sleep 5

	wait_for_closing_machines
    fi
}


echo "Sleep the virtual machines."

while read -r machine; do
    echo "vboxmanage controlvm \"${machine}\" savestate"

    if [ ${DRY_RUN} -eq 0 ]; then
	vboxmanage controlvm "${machine}" savestate
    fi
done <<< "${MACHINES}"

if [ ${DRY_RUN} -eq 0 ]; then
    wait_for_closing_machines
fi


echo "Run backup."

ulimit -n 2048

backupOperation "${PARAM_DRY_RUN}"

echo "Wake the virtual machines."

while read -r machine; do
    echo "vboxmanage startvm \"${machine}\" --type headless"

    if [ ${DRY_RUN} -eq 0 ]; then
	vboxmanage startvm "${machine}" --type headless
    fi
done <<< "${MACHINES}"


echo "Mail backup logs."

cat backup.mail backup.log | msmtp -a default "${MAILTO}"


source backup-settings.sh unset

