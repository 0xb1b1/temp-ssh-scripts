#!/bin/sh

# This script adds support for ATOM ML SSH certificates.

SSH_HOME_PATH="$HOME/.ssh"
KNOWN_HOSTS_CERT_AUTHORITY='@cert-authority *.eu-north1.nebius.vm.atomml.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDpTSW6uw+sL419ggZlXGQdGIZX+XqnvvL4dYDJtBUM6 atomml_host_ca'

read_atom_credentials() {
    printf "Enter your ATOM email address: " >&2
    read -r ATOM_EMAIL_ADDRESS
    export ATOM_EMAIL_ADDRESS
}

check_ssh_home() {
    if [ ! -d "${SSH_HOME_PATH}" ]; then
        echo "SSH Home path ($}) doesn't exist, halting..."
        exit 1;
    fi
}

check_ed25519_key() {
    if [ ! -f "${SSH_HOME_PATH}/id_ed25519" ]; then
        echo "No ed25519 key found in ${SSH_HOME_PATH}, halting..."
        echo "To create this key, run \`ssh-keygen -t ed25519 -C ${ATOM_EMAIL_ADDRESS}\`"
        exit 1;
    fi

    if [ ! -f "${SSH_HOME_PATH}/id_ed25519.pub" ]; then
        echo "No ed25519 public key found in ${SSH_HOME_PATH}, halting..."
        exit 1;
    fi
}

ensure_known_hosts() {
    echo "Ensuring known hosts file exists..."
    if [ ! -f "${SSH_HOME_PATH}/known_hosts" ]; then
        echo "No known hosts file found, creating..."
        touch "${SSH_HOME_PATH}/known_hosts"
        echo "Created known hosts file in ${SSH_HOME_PATH}"
    else
        echo "Known hosts file already exists at ${SSH_HOME_PATH}, skipping..."
    fi
}

ensure_ssh_config() {
    if [ ! -f "${SSH_HOME_PATH}/config" ]; then
        echo "No ssh config file found, creating..."
        touch "${SSH_HOME_PATH}/config"
        echo "Created ssh config file in ${SSH_HOME_PATH}"
    else
        echo "ssh config file found, skipping creation..."
    fi
}

ensure_cert_authority_known_hosts() {
    echo "Ensuring known hosts entry for ${KNOWN_HOSTS_CERT_AUTHORITY}..."
    # Check if line ${KNOWN_HOSTS_CERT_AUTHORITY} exists in ${SSH_HOME_PATH}/known_hosts
    if grep -Fxq "$KNOWN_HOSTS_CERT_AUTHORITY" "${SSH_HOME_PATH}/known_hosts"; then
        echo "Known hosts entry for ${KNOWN_HOSTS_CERT_AUTHORITY} already exists, skipping..."
    else
        echo "No known hosts entry for \"${KNOWN_HOSTS_CERT_AUTHORITY}\", adding..."
        # the following string should have only letters and numbers, no spaces, no special characters
        RANDOM_STRING_TEMP_CERT_AUTHORITY=$(LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)
        TEMP_ADD_CERT_AUTHORITY_PATH="${SSH_HOME_PATH}/temp_ensure_cert_authority_${RANDOM_STRING_TEMP_CERT_AUTHORITY}.txt"
        echo "${KNOWN_HOSTS_CERT_AUTHORITY}" | cat - "${SSH_HOME_PATH}/known_hosts" > "${TEMP_ADD_CERT_AUTHORITY_PATH}" && mv "${TEMP_ADD_CERT_AUTHORITY_PATH}" "${SSH_HOME_PATH}/known_hosts"
    fi
}

ensure_ssh_config_entry() {
    echo "Ensuring ssh config entry..."
    if grep -Fxq 'Host *.eu-north1.nebius.vm.atomml.net' "${SSH_HOME_PATH}/config"; then
        echo "ssh config entry already exists, skipping..."
    else
        echo "No ssh config entry found, adding..."
        printf "\nHost *.eu-north1.nebius.vm.atomml.net\n  User atomml\n  IdentitiesOnly yes\n  IdentityFile ~/.ssh/id_ed25519" >> "${SSH_HOME_PATH}/config"
    fi
}

print_pubkey_and_instructions() {
    printf "\n\nSend the following information to a DevOps Engineer:\n---\nPublic key (ed25519): "
    cat "${SSH_HOME_PATH}/id_ed25519.pub"
    printf "\nEmail address: %s" "${ATOM_EMAIL_ADDRESS}"

    printf "\n---"

    printf "\n\nAfter you received your certificate (id_ed25519-cert.pub), place it under \"%s\"" "${SSH_HOME_PATH}"
    printf "\nAnd execute \`chmod 644 %s/id_ed25519-cert.pub\`\n" "${SSH_HOME_PATH}"
}


main() {
    read_atom_credentials

    check_ssh_home
    check_ed25519_key
    ensure_ssh_config
    ensure_ssh_config_entry
    ensure_known_hosts
    ensure_cert_authority_known_hosts

    print_pubkey_and_instructions
}

main
