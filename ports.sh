#!/bin/bash

#
# Show the exposed network / NAT port forwarding configuration
# for all running VMs.
#

MACHINES=$(vboxmanage list runningvms | cut -f 2 -d \")

echo "Networking setup looks like:"
echo ""

while read -r machine; do
    echo "vboxmanage showvminfo \"${machine}\""
    vboxmanage showvminfo "${machine}" | grep "^NIC" | grep -v "disabled"

    echo ""
done <<< "${MACHINES}"
