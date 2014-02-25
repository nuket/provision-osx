#!/bin/bash

#
# Usage: 
# 
# backup.sh [-d] [-n name] [-R] [-N]
#
#     -d    Dry run
#     -n    Name of VM to backup
#     -R    Reset the VM after backup
#     -N    Do not start VM after backup
#

# Read in passwords and other settings from separate, non-checked-in file.
#
# It needs to provide the following environment variables:
#
# SFTP_TARGET
# PASSPHRASE
# FTP_PASSWORD
# MAILTO
#

source backup-settings.sh set

DRY_RUN=""
VMNAME=""
START_VM=1
RESET_VM=0

# See: http://www.pclinuxos.com/forum/index.php?topic=103651.0

while getopts ":dn:RN" opt; do
    case $opt in
	d)
	    echo "Dry run."
	    DRY_RUN="--dry-run"
	    ;;
	n) 
	    VMNAME="${OPTARG}"
	    echo "Backing up single VM: ${VMNAME}"
	    ;;
	N)
	    echo "Don't start the VM again after backup."
	    START_VM=0
	    ;;
	R)
	    echo "Reset the VM after starting it again."
	    RESET_VM=1
	    ;;
    esac
done

if [ -z "${VMNAME}" ]; then
    echo "No virtual machine name specified."
else
    RUNNING=$(vboxmanage list runningvms | grep "${VMNAME}" | wc -l | tr -d ' ')

    if [ "${RUNNING}" -eq "1" ]; then
	echo "Sleep the virtual machine: ${VMNAME}"

	echo "vboxmanage controlvm \"${VMNAME}\" savestate"
	vboxmanage controlvm "${VMNAME}" savestate
    fi

    SOURCE_FOLDER=$(find ~/VirtualBox\ VMs -name "${VMNAME}" -type d)
    TARGET_FOLDER="sftp://${SFTP_TARGET}/VMs/${VMNAME}"

    if [ -n "${SOURCE_FOLDER}" ]; then
	echo "Run backup: \"${SOURCE_FOLDER}\" \"${TARGET_FOLDER}\""

	ulimit -n 2048

	duplicity remove-all-but-n-full 2 ${DRY_RUN} --force            "${TARGET_FOLDER}"                            
	duplicity --full-if-older-than 1W ${DRY_RUN} "${SOURCE_FOLDER}" "${TARGET_FOLDER}"
    fi

    RUNNING=$(vboxmanage list runningvms | grep "${VMNAME}" | wc -l | tr -d ' ')

    if [ "${RUNNING}" -eq "0" ] && [ "${START_VM}" -eq "1" ]; then
	echo "Wake the virtual machine: ${VMNAME}"

	echo "vboxmanage startvm \"${VMNAME}\" --type headless"
	vboxmanage startvm "${VMNAME}" --type headless
    fi

    if [ "$START_VM" -eq "1" ] && [ "${RESET_VM}" -eq "1" ]; then
	echo "Reset the restarted VM."
	sleep 30

	vboxmanage controlvm "${VMNAME}" reset
    fi

    echo "Mail backup logs."

    cat backup.mail backup.log | msmtp -a default "${MAILTO}"
fi

source backup-settings.sh unset

