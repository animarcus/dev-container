FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Define build arguments with defaults
ARG DEV_USER=vscode
ARG PUID=1000
ARG PGID=1000

# Set as environment variables for runtime
ENV DEV_USER=$DEV_USER \
    PUID=$PUID \
    PGID=$PGID \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ZSH_CUSTOM=/etc/oh-my-zsh/custom

# Install required packages
RUN --mount=type=cache,target=/var/cache/apt \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    locales \
    fonts-powerline \
    #
    # neovim
    # ripgrep, wget, maybe tmux or whatever
    # Add your development tools here
    && apt-get clean \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/* \
    # Set up ZSH plugins in the same layer
    && mkdir -p ${ZSH_CUSTOM}/plugins ${ZSH_CUSTOM}/themes \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting \
    && git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM}/plugins/fast-syntax-highlighting \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k


# Copy base configurations
COPY configs/common /etc/dev/common
COPY ./environments/base/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
