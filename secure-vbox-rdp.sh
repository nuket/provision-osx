#!/bin/bash

# By default, don't use a different certificate for each VM.
PER_MACHINE_CERTS=0

# Overwrite certificates
OVERWRITE_CERTS=0

# Clear certificates from virtual machine.
CLEAR_CERTS=0

# Use null authentication, but specify the localhost port where
# you can connect to the VM.
# 
# Use this with SSH tunnels, of the form:
#
#     ssh -fCNq -L some-local-port:localhost:VRDE_PORT vmhost.domain.com
#
NULL_AUTH=0

# The port at which the VRDE server listens.
VRDE_PORT=0

while getopts ":v:u:p:ifCNP:" opt; do
    case $opt in
	v)
	    echo "Modifying VM: ${OPTARG}"
	    VM_NAME="${OPTARG}"
	    ;;
	u)
	    echo "Setting username: ${OPTARG}"
	    USERNAME="${OPTARG}"
	    ;;
	p)
	    echo "Setting password: ${OPTARG}"
	    PASSWORD="${OPTARG}"
	    ;;
	i)
	    echo "Using individual certificates."
	    PER_MACHINE_CERTS=1
	    ;;
	f)
	    echo "Overwriting certificates."
	    OVERWRITE_CERTS=1
	    ;;
	C)
	    echo "Clearing certificates for machine."
	    CLEAR_CERTS=1
	    ;;
	N)
	    echo "Setting --vrdeauthtype to 'null'."
	    NULL_AUTH=1
	    ;;
	P)
	    echo "Setting VDRE port."
	    VRDE_PORT="${OPTARG}"
	    ;;
    esac
done

createUser () {
    VBoxManage setproperty vrdeauthlibrary "VBoxAuthSimple"
    VBoxManage modifyvm "${VM_NAME}" --vrdeauthtype external
    HASH=$(VBoxManage internalcommands passwordhash "${PASSWORD}" | sed "s_Password hash: __g")
    VBoxManage setextradata "${VM_NAME}" "VBoxAuthSimple/users/${USERNAME}" "${HASH}"
}

createCertificate () {
    if [ ${PER_MACHINE_CERTS} -eq 1 ]; then
	VM_PATH="${HOME}/VirtualBox VMs/${VM_NAME}"
    else
	VM_PATH="${HOME}/VirtualBox VMs"
    fi

    if [ ${OVERWRITE_CERTS} -eq 0 ]; then
	if [ -f "${VM_PATH}/ca_cert.pem" ] && [ -f "${VM_PATH}/server_cert.pem" ] && [ -f "${VM_PATH}/server_key_private.pem" ]; then
	    echo "Don't overwrite certificates."
	    return
	fi
    fi

    VBoxManage modifyvm "${VM_NAME}" --vrdeproperty "Security/Method=TLS"

    openssl req -new -x509 -days 730 -extensions v3_ca -keyout "${VM_PATH}/ca_key_private.pem" -out "${VM_PATH}/ca_cert.pem"
    openssl genrsa -out "${VM_PATH}/server_key_private.pem"
    openssl req -new -key "${VM_PATH}/server_key_private.pem" -out "${VM_PATH}/server_req.pem"
    openssl x509 -req -days 730 -in "${VM_PATH}/server_req.pem" -CA "${VM_PATH}/ca_cert.pem" -CAkey "${VM_PATH}/ca_key_private.pem" -set_serial 01 -out "${VM_PATH}/server_cert.pem"

    VBoxManage modifyvm "${VM_NAME}" --vrdeproperty "Security/CACertificate=${VM_PATH}/ca_cert.pem"
    VBoxManage modifyvm "${VM_NAME}" --vrdeproperty "Security/ServerCertificate=${VM_PATH}/server_cert.pem"
    VBoxManage modifyvm "${VM_NAME}" --vrdeproperty "Security/ServerPrivateKey=${VM_PATH}/server_key_private.pem"
}

clearCertificates() {
    VM_PATH="${HOME}/VirtualBox VMs/${VM_NAME}"

    rm "${VM_PATH}/*.pem"
    
    VBoxManage modifyvm "${VM_NAME}" --vrdeproperty "Security/Method=Negotiate"
    
    VBoxManage modifyvm "${VM_NAME}" --vrdeproperty "Security/CACertificate="
    VBoxManage modifyvm "${VM_NAME}" --vrdeproperty "Security/ServerCertificate="
    VBoxManage modifyvm "${VM_NAME}" --vrdeproperty "Security/ServerPrivateKey="
}

# If the RDP server is going to have no authentication
# then the rule is to only allow it to serve via localhost:port
#
# You can then use SSH tunnelling to connect safely.
nullAuth() {
    VBoxManage modifyvm "${VM_NAME}" --vrdeauthtype "null"
    VBoxManage modifyvm "${VM_NAME}" --vrdeaddress  "127.0.0.1"
    VBoxManage modifyvm "${VM_NAME}" --vrdeport     "${VRDE_PORT}"

    echo "You can now connect to the VM at localhost:${VRDE_PORT}."
}

usage () {
    echo "Usage: "
    echo ""
    echo "$0 -v [virtual machine] -u [username] -p [password] (optional -i)"
    echo ""
    echo "    Creates a TLS-secured user/password on the virtual machine,"
    echo "    using a single certificate for the entire virtual machine host."
    echo ""
    echo "$0 -v [virtual machine] -C"
    echo ""
    echo "    Clears certificates from a single virtual machine."
    echo ""
    echo "$0 -v [virtual machine] -N -P [vdre port]"
    echo ""
    echo "    Resets authentication to null, sets listening interface to"
    echo "    localhost, sets port to specified value. Useful for ssh-tunneling."
    echo ""
}

if [ -n "${VM_NAME}" ] && [ -n "${USERNAME}" ] && [ -n "${PASSWORD}" ]; then
    createUser "${USERNAME}" "${PASSWORD}"
    createCertificate
elif [ -n "${VM_NAME}" ] && [ ${CLEAR_CERTS} -eq 1 ]; then
    clearCertificates
elif [ -n "${VM_NAME}" ] && [ ${NULL_AUTH} -eq 1 ] && [ ${VRDE_PORT} -ne 0 ]; then
    nullAuth
else
    usage
fi
