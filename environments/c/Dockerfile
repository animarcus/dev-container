FROM dev-container-baase:latest

# Install C development tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    gdb \
    valgrind \
    clang \
    clang-format \
    clang-tidy \
    && rm -rf /var/lib/apt/lists/*

# Copy C specific configurations
COPY configs/env-specific/c /etc/dev/env-specific/c
