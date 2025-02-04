FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04 AS base

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

# mkdir -p /run/sshd
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG PUID=501
ARG PGID=20

# Copy only necessary files from the build stage
COPY --from=build /etc/ssh /etc/ssh
COPY --from=build /home/vscode/.ssh /home/vscode/.ssh

# Set user permissions last to ensure everything is owned correctly
RUN usermod -u ${PUID} vscode && \
    usermod -g ${PGID} vscode

# Copy SSH configuration files with explicit paths
COPY --chown=vscode:vscode configs/ssh/authorized_keys /home/vscode/.ssh/authorized_keys

# Set final permissions
RUN chmod 600 /home/vscode/.ssh/authorized_keys && \
    chown -R vscode:vscode /home/vscode/.ssh && \
    mkdir -p /run/sshd

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
