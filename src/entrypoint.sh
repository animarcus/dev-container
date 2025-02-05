#!/usr/bin/env bash
set -e

# Enable debug mode if needed
# set -x

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check required environment variables
check_environment() {
    if [ -z "$PUID" ] || [ -z "$PGID" ]; then
        log "Error: PUID or PGID not set"
        exit 1
    fi

    log "Starting container with PUID: $PUID, PGID: $PGID"
}

# Function to set up permissions
setup_permissions() {
    log "Setting up permissions..."

    # Ensure the group exists
    groupmod -o -g "$PGID" vscode || groupadd -g "$PGID" vscode

    # Ensure the user exists
    usermod -o -u "$PUID" vscode || useradd -u "$PUID" -g "$PGID" -m vscode

    # Set up home directory permissions
    chown -R vscode:vscode /home/vscode

    # Set up SSH directory
    if [ ! -d /home/vscode/.ssh ]; then
        mkdir -p /home/vscode/.ssh
    fi
    chmod 700 /home/vscode/.ssh

    # Set up authorized_keys if it exists
    if [ -f /home/vscode/.ssh/authorized_keys ]; then
        chmod 600 /home/vscode/.ssh/authorized_keys
        chown vscode:vscode /home/vscode/.ssh/authorized_keys
    fi

    # Set up workspace directory if mounted
    if [ -d /workspace ]; then
        chown vscode:vscode /workspace
    fi

    log "Permissions setup completed"
}

# Function to configure SSH
setup_ssh() {
    log "Configuring SSH..."

    # Generate SSH host keys if they don't exist
    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        ssh-keygen -A
    fi

    # Configure SSH
    {
        echo "UsePAM no"
        echo "PermitRootLogin no"
        echo "AllowUsers vscode"
        echo "LogLevel DEBUG3"
        echo "PasswordAuthentication no"
    } >>/etc/ssh/sshd_config

    mkdir -p /run/sshd

    log "SSH configuration completed"
}

# Main execution
main() {
    log "Starting initialization..."

    check_environment
    setup_permissions
    setup_ssh

    log "Initialization completed. Starting SSH daemon..."
    exec /usr/sbin/sshd -D -e
}

main "$@"
