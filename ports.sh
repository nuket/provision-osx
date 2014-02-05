#!/bin/bash

#
# Show the exposed network / NAT port forwarding configuration
# for all running VMs.
#

MACHINES=$(vboxmanage list vms | cut -f 2 -d \")

echo "Networking setup looks like:"
echo ""

while read -r machine; do
    echo "vboxmanage showvminfo \"${machine}\""
    vboxmanage showvminfo "${machine}" | grep "^NIC" | grep -v "disabled"
    vboxmanage showvminfo "${machine}" | grep "^VRDE:"

    echo ""
done <<< "${MACHINES}"
