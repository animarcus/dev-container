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

    # Get or create group
    GROUP_NAME=$(getent group "${PGID}" | cut -d: -f1)
    if [ -z "$GROUP_NAME" ]; then
        log "Creating group with GID ${PGID}"
        groupadd -g "${PGID}" devgroup
        GROUP_NAME="devgroup"
    fi
    log "Using group: ${GROUP_NAME} (${PGID})"

    # Handle user creation/modification
    if id "$DEV_USER" >/dev/null 2>&1; then
        log "User $DEV_USER exists, updating properties..."
        usermod -u "${PUID}" "${DEV_USER}"
        usermod -g "${PGID}" "${DEV_USER}"
    elif id vscode >/dev/null 2>&1; then
        log "Converting vscode user to ${DEV_USER}..."
        usermod -l "${DEV_USER}" vscode
        usermod -u "${PUID}" "${DEV_USER}"
        usermod -g "${PGID}" "${DEV_USER}"
        usermod -d "/home/${DEV_USER}" "${DEV_USER}"

        # Migrate existing home directory
        if [ -d "/home/vscode" ] && [ "$(ls -A /home/vscode)" ]; then
            log "Migrating vscode home contents"
            mkdir -p "/home/${DEV_USER}"
            cp -a /home/vscode/. "/home/${DEV_USER}/"
        fi
    else
        log "Creating new user ${DEV_USER}..."
        useradd -m -u "${PUID}" -g "${PGID}" -s /bin/zsh "${DEV_USER}"
    fi

    # Ensure home directory exists
    mkdir -p "/home/${DEV_USER}"

    # Set up SSH configuration
    log "Setting up SSH configuration..."
    mkdir -p "/home/${DEV_USER}/.ssh"

    if [ -f "/etc/dev/common/ssh/authorized_keys" ]; then
        log "Setting up SSH keys"
        cp "/etc/dev/common/ssh/authorized_keys" "/home/${DEV_USER}/.ssh/"
        chmod 700 "/home/${DEV_USER}/.ssh"
        chmod 600 "/home/${DEV_USER}/.ssh/authorized_keys"
    else
        log "WARNING: No authorized_keys file found"
    fi
}

# Set ownership of files and directories with progress indicators
setup_permissions() {
    local start_time
    local home_path="/home/${DEV_USER}"

    log "Setting up ownership for ${DEV_USER}:${GROUP_NAME}"

    # Fix ownership of the home directory itself (non-recursive)
    chown "${DEV_USER}:${GROUP_NAME}" "$home_path" 2>/dev/null || true

    # Option to recursively set ownership
    RECURSIVE_CHOWN=${RECURSIVE_CHOWN:-"false"}

    if [ "$RECURSIVE_CHOWN" = "true" ]; then
        log "Starting recursive ownership change for entire home directory..."
        log "This may take a while for large directories"
        start_time=$(date +%s)

        # Create a simple progress counter
        progress_file="/tmp/chown_progress"
        echo "0" >"$progress_file"

        # Start background process to show progress every 5 seconds
        (
            while [ -f "$progress_file" ]; do
                if [ -f "$progress_file" ]; then
                    current=$(cat "$progress_file")
                    elapsed=$(($(date +%s) - start_time))
                    if [ $elapsed -gt 0 ]; then
                        log "Processed files: $current, elapsed time: ${elapsed}s"
                    fi
                fi
                sleep 5
            done
        ) &
        progress_pid=$!

        # Process files in batches for better performance
        find "$home_path" -xdev -print0 | while IFS= read -d $'\0' -r file; do
            chown -f "${DEV_USER}:${GROUP_NAME}" "$file" 2>/dev/null || true
            count=$(($(cat "$progress_file") + 1))
            echo "$count" >"$progress_file"
        done

        # Clean up progress monitoring
        rm -f "$progress_file"
        kill $progress_pid 2>/dev/null || true

        total_time=$(($(date +%s) - start_time))
        log "Recursive ownership complete! Took ${total_time} seconds"
    else
        # Fix ownership of critical dot-directories
        log "Setting ownership of configuration directories"
        for dir in .ssh .config .cache .oh-my-zsh .local .npm .nvm bin; do
            dir_path="$home_path/$dir"
            if [ -d "$dir_path" ]; then
                log "  - $dir_path"
                chown -R "${DEV_USER}:${GROUP_NAME}" "$dir_path" 2>/dev/null || true
            fi
        done

        # Fix ownership of dotfiles in home directory (non-recursive)
        log "Setting ownership of configuration files"
        find "$home_path" -maxdepth 1 -name ".*" -type f -print0 | xargs -0 -r chown "${DEV_USER}:${GROUP_NAME}" 2>/dev/null || true

        log "Skipped recursive ownership for mounted directories and large volumes"
        log "To enable recursive ownership, set RECURSIVE_CHOWN=true in your .env file"
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

    # Ensure custom directories exist
    mkdir -p "${DEV_HOME}/.oh-my-zsh/custom/plugins"
    mkdir -p "${DEV_HOME}/.oh-my-zsh/custom/themes"

    # Copy plugins and themes from /etc
    cp -r /etc/oh-my-zsh/custom/plugins/* "${DEV_HOME}/.oh-my-zsh/custom/plugins/"
    cp -r /etc/oh-my-zsh/custom/themes/* "${DEV_HOME}/.oh-my-zsh/custom/themes/"

    # Set correct permissions
    chown -R "${DEV_USER}:$(id -gn "${DEV_USER}")" "${DEV_HOME}/.oh-my-zsh"
    chown "${DEV_USER}:$(id -gn "${DEV_USER}")" "${DEV_HOME}/.zshrc" "${DEV_HOME}/.p10k.zsh"

    # Set ZSH as default shell
    chsh -s "$(which zsh)" "${DEV_USER}"
}

setup_scripts() {
    log "Setting up utility custom scripts..."

    # Ensure ~/bin dir exists
    mkdir -p "$DEV_HOME/bin"

    # Create symlinks for trews and universal copy
    ln -sf /etc/dev/common/scripts/trews/trews.sh "$DEV_HOME/bin/trews"
    ln -sf /etc/dev/common/scripts/trews/universal-copy.sh "$DEV_HOME/bin/universal-copy"

    # Set correct permissions for the bin and links
    chown -R "${DEV_USER}:$(id -gn "${DEV_USER}")" "$DEV_HOME/bin"
    chmod -R 755 "$DEV_HOME/bin"

    log "Utility scripts symlinked in ~/bin"
}

# Main
main() {
    log "Starting initialization..."
    check_environment
    setup_user
    setup_permissions
    setup_ssh
    setup_zsh
    setup_scripts

    # Get external SSH port for connection info
    EXTERNAL_SSH_PORT=${SSH_PORT:-2222}

    log "Starting SSH daemon..."
    log "=========================================================="
    log "CONNECTION INFORMATION:"
    log "   SSH Command: ssh -p ${EXTERNAL_SSH_PORT} ${DEV_USER}@localhost"
    log ""
    log "   For easier connection, add this to your ~/.ssh/config:"
    log "   Host dev-container"
    log "       Port ${EXTERNAL_SSH_PORT}"
    log "       User ${DEV_USER}"
    log "       HostName localhost"
    log "       StrictHostKeyChecking no"
    log "=========================================================="

    # Run sshd with reduced verbosity but still in foreground
    exec /usr/sbin/sshd -D -e
}

main "$@"
