FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Define build arguments with defaults
ARG DEV_USER=devuser
ARG PUID=1000
ARG PGID=1000

# Set as environment variables for runtime
ENV DEV_USER=$DEV_USER \
    PUID=$PUID \
    PGID=$PGID \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server \
    locales \
    fonts-powerline \
    #
    # neovim
    # ripgrep, wget, maybe tmux or whatever
    # Add your development tools here
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Set up ZSH plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting


# Copy base configurations
COPY configs/common /etc/dev/common
COPY ./environments/base/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
