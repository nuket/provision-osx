#!/bin/bash

# By default, don't use a different certificate for each VM.
PER_MACHINE_CERTS=0

while getopts ":v:u:p:iC" opt; do
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

	# Don't overwrite common certificates.
	if [ -f "${VM_PATH}/ca_cert.pem" ] && [ -f "${VM_PATH}/server_cert.pem" ] && [ -f "${VM_PATH}/server_key_private.pem" ]; then
	    echo "Don't overwrite common certificates."
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

usage () {
    echo ""
    echo "$0 -v [virtual machine] -u [username] -p [password]"
    echo ""
}

if [ -n "${VM_NAME}" ] && [ -n "${USERNAME}" ] && [ -n "${PASSWORD}" ]; then
    createUser "${USERNAME}" "${PASSWORD}"
    createCertificate
else
    usage
fi
