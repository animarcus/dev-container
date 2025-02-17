FROM dev-container-base:latest

# Install essential C development tools
RUN apt-get update && \
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
    && rm -rf /var/lib/apt/lists/*

# Copy C specific configurations
COPY configs/env-specific/c /etc/dev/env-specific/c
