FROM dev-container-base:latest

# Add environment-specific tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends
# package1 \
# package2    Add continuation lines with \ and don't forget &&

# Add any environment-specific configuration
COPY configs/env-specific/env /etc/dev/env-specific
