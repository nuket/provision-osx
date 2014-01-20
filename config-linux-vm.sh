#!/bin/bash

while getopts ":v:P:" opt; do
    case $opt in
	v)
	    echo "Modifying VM: ${OPTARG}"
	    VM_NAME="${OPTARG}"
	    ;;
	P)
	    echo "Setting VDRE port."
	    VRDE_PORT="${OPTARG}"
	    ;;
    esac
done

basicConfig () {
    VBoxManage modifyvm "${VM_NAME}" --memory 384 --acpi on --ioapic on --rtcuseutc on --accelerate2dvideo on
    VBoxManage modifyvm "${VM_NAME}" --bioslogofadein off --bioslogofadeout off --bioslogodisplaytime 250
    VBoxManage modifyvm "${VM_NAME}" --keyboard ps2 --mouse ps2
    VBoxManage modifyvm "${VM_NAME}" --audio none    
    VBoxManage modifyvm "${VM_NAME}" --usb off
    VBoxManage modifyvm "${VM_NAME}" --nic1 nat
    VBoxManage modifyvm "${VM_NAME}" --boot1 dvd 
}

# If the RDP server is going to have no authentication
# then the rule is to only allow it to serve via localhost:port
#
# You can then use SSH tunnelling to connect safely.
nullAuth () {
    VBoxManage modifyvm "${VM_NAME}" --vrde on
    VBoxManage modifyvm "${VM_NAME}" --vrdeauthtype "null"
    VBoxManage modifyvm "${VM_NAME}" --vrdeaddress  "127.0.0.1"
    VBoxManage modifyvm "${VM_NAME}" --vrdeport     "${VRDE_PORT}"
    VBoxManage modifyvm "${VM_NAME}" --vrdemulticon "on"

    echo "You can now connect to the VM at localhost:${VRDE_PORT}."
}

usage () {
    echo "Usage: "
    echo ""
    echo "$0 -v [virtual machine] -P [vdre port]"
    echo ""
    echo "    Resets authentication to null, sets listening interface to"
    echo "    localhost, sets port to specified value. Useful for ssh-tunneling."
    echo ""
}

if [ -n "${VM_NAME}" ] && [ ${VRDE_PORT} -ne 0 ]; then
    basicConfig
    nullAuth
else
    usage
fi
