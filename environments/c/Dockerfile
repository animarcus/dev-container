FROM dev-container-base:latest

# Install essential C development tools
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Basic development tools
    # Includes gcc and make
    build-essential \
    # Debugger
    gdb \
    # Alternative compiler
    clang \
    # Memory checker
    valgrind \
    # Manual pages
    man-db \
    # From the project guidelines
    manpages \
    # For scan-build and others
    clang-tools \
    check \
    manpages-dev \
    doxygen \
    graphviz \
    libssl-dev \
    libssl-doc \
    libvips-dev \
    libjson-c-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy C specific configurations
COPY configs/env-specific/c /etc/dev/env-specific/c
