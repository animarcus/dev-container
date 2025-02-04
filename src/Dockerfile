FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Accept UID and GID as build arguments
ARG PUID=501
ARG PGID=20

# Install SSH server first
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/sshd

# Generate host keys
RUN ssh-keygen -A

# Setup SSH directories with proper ownership and permissions
RUN mkdir -p /home/vscode/.ssh && \
    chmod 700 /home/vscode/.ssh && \
    chown -R vscode:vscode /home/vscode/.ssh

# Copy SSH configuration files with explicit paths
COPY --chown=vscode:vscode configs/ssh/authorized_keys /home/vscode/.ssh/authorized_keys

# Set permissions after copy
RUN chmod 600 /home/vscode/.ssh/authorized_keys && \
    chown vscode:vscode /home/vscode/.ssh/authorized_keys

# Set final permissions
RUN chmod 644 /etc/ssh/sshd_config && \
    chmod 600 /home/vscode/.ssh/authorized_keys && \
    chown -R vscode:vscode /home/vscode/.ssh && \
    # Set user permissions last to ensure everything is owned correctly
    usermod -u ${PUID} vscode && \
    usermod -g ${PGID} vscode

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
