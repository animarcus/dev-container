FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server \
    # Add your development tools here
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /home/vscode/.ssh

# Copy configurations
COPY configs/ssh/authorized_keys /home/vscode/.ssh/authorized_keys
# Add other config copies as needed


# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
