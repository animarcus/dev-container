FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Define build arguments with defaults
ARG DEV_USER=devuser
ARG PUID=1000
ARG PGID=1000

# Set as environment variables for runtime
ENV DEV_USER=$DEV_USER \
    PUID=$PUID \
    PGID=$PGID

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server \
    #
    # neovim
    # ripgrep, wget, maybe tmux or whatever
    # Add your development tools here
    && rm -rf /var/lib/apt/lists/*

# Set up ZSH plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Copy base configurations
COPY configs/common /etc/dev/common
COPY ./environments/base/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
