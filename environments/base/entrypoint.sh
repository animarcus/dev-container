#!/usr/bin/env bash
set -e

# Redirect all output to stderr for Docker logging
exec 1>&2

PUID=$(echo "$PUID" | grep -o '^[0-9]\+$' || echo "1000")
PGID=$(echo "$PGID" | grep -o '^[0-9]\+$' || echo "1000")
DEV_USER=$(echo "$DEV_USER" | tr -cd '[:alnum:]_-')
DEV_HOME="/home/${DEV_USER}"

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >&2
}

# Debug function for file/directory info
debug_ls() {
    local path="$1"
    log "Listing contents of: $path"
    ls -la "$path" 2>&1 || log "Failed to list: $path"
}

# Check environment
check_environment() {
    if ! [[ "$PUID" =~ ^[0-9]+$ ]] || ! [[ "$PGID" =~ ^[0-9]+$ ]] || [ -z "$DEV_USER" ]; then
        log "Error: Invalid environment variables"
        log "PUID (must be numeric): $PUID"
        log "PGID (must be numeric): $PGID"
        log "DEV_USER (must not be empty): $DEV_USER"
        exit 1
    fi

    log "Starting container with:"
    log "PUID: ${PUID}"
    log "PGID: ${PGID}"
    log "DEV_USER: ${DEV_USER}"
}

# Setup user and permissions
setup_user() {
    log "Setting up user..."

    if id vscode >/dev/null 2>&1; then
        log "Found vscode user, modifying..."

        # Get the group name for PGID
        GROUP_NAME=$(getent group "${PGID}" | cut -d: -f1)
        log "Using group: ${GROUP_NAME} (${PGID})"

        # Rename vscode user to DEV_USER
        usermod -l "${DEV_USER}" vscode

        # Update UID/GID
        usermod -u "${PUID}" "${DEV_USER}"
        usermod -g "${PGID}" "${DEV_USER}"

        # Update home directory
        usermod -d "/home/${DEV_USER}" "${DEV_USER}"

        # Handle home directory with volume mount
        if [ -d "/home/vscode" ]; then
            log "Found vscode home directory"
            mkdir -p "/home/${DEV_USER}"

            if [ "$(ls -A /home/vscode)" ]; then
                log "Copying vscode home contents"
                cp -a /home/vscode/. "/home/${DEV_USER}/"
            fi
        fi

        # Set up SSH
        log "Setting up SSH configuration..."
        debug_ls "/etc/dev/common/ssh"

        mkdir -p "/home/${DEV_USER}/.ssh"

        if [ -f "/etc/dev/common/ssh/authorized_keys" ]; then
            log "Found authorized_keys file"
            cp "/etc/dev/common/ssh/authorized_keys" "/home/${DEV_USER}/.ssh/"
            chmod 700 "/home/${DEV_USER}/.ssh"
            chmod 600 "/home/${DEV_USER}/.ssh/authorized_keys"
            debug_ls "/home/${DEV_USER}/.ssh"

            # log "Authorized keys content (first line):"
            head -n 1 "/home/${DEV_USER}/.ssh/authorized_keys"
        else
            log "WARNING: No authorized_keys file found!"
            debug_ls "/etc/dev/common"
        fi

        # Set ownership using proper group name
        log "Setting ownership to ${DEV_USER}:${GROUP_NAME}"
        chown -R "${DEV_USER}:${GROUP_NAME}" "/home/${DEV_USER}"
    else
        log "Error: vscode user not found in base image"
        exit 1
    fi
}

# Setup SSH
setup_ssh() {
    log "Setting up SSH daemon..."
    mkdir -p /run/sshd

    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        log "Generating SSH host keys..."
        ssh-keygen -A
    fi

    log "Configuring SSH daemon..."
    {
        echo "UsePAM no"
        echo "PermitRootLogin no"
        echo "AllowUsers ${DEV_USER}"
        echo "PasswordAuthentication no"
    } >>/etc/ssh/sshd_config

    # Verify config
    log "SSH config contents:"
    grep -E "^(UsePAM|PermitRootLogin|AllowUsers|PasswordAuthentication)" /etc/ssh/sshd_config
}

setup_zsh() {
    log "Setting up ZSH configuration..."

    # Copy ZSH configurations
    cp /etc/dev/common/oh-my-zsh-setup/.zshrc "${DEV_HOME}/.zshrc"
    cp /etc/dev/common/oh-my-zsh-setup/.p10k.zsh "${DEV_HOME}/.p10k.zsh"

    # Set correct permissions
    chown "${DEV_USER}:$(id -gn "${DEV_USER}")" "${DEV_HOME}/.zshrc" "${DEV_HOME}/.p10k.zsh"

    # Set ZSH as default shell for the user
    chsh -s "$(which zsh)" "${DEV_USER}"

    # Copy Oh My Zsh configurations to the correct location
    cp -r /root/.oh-my-zsh "${DEV_HOME}/.oh-my-zsh"
    chown -R "${DEV_USER}:$(id -gn "${DEV_USER}")" "${DEV_HOME}/.oh-my-zsh"
}

# Main
main() {
    log "Starting initialization..."
    check_environment
    setup_user
    setup_ssh
    setup_zsh
    log "Starting SSH daemon..."
    exec /usr/sbin/sshd -D -e
}

main "$@"
