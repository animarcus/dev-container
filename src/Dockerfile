FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG PUID
ARG PGID

ENV PUID=${PUID}
ENV PGID=${PGID}

RUN echo "Building with PUID=${PUID} and PGID=${PGID}"

# Install SSH server and generate host keys in a single layer
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    ssh-keygen -A

# Setup SSH directory
RUN mkdir -p /home/vscode/.ssh

# Copy authorized_keys and set permissions in one step
COPY --chown=vscode:vscode configs/ssh/authorized_keys /home/vscode/.ssh/authorized_keys

# Set user permissions and then apply file permissions
RUN usermod -u ${PUID} vscode && \
    usermod -g ${PGID} vscode && \
    chmod 700 /home/vscode/.ssh && \
    chmod 600 /home/vscode/.ssh/authorized_keys && \
    chown -R vscode:vscode /home/vscode/.ssh && \
    mkdir -p /run/sshd

RUN echo "UsePAM no" >> /etc/ssh/sshd_config && \
    echo "LogLevel DEBUG3" >> /etc/ssh/sshd_config

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-e"]
