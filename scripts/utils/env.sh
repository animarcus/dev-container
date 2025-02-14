#!/usr/bin/env bash

# Load environment variables
if [ -f .env ]; then
    # shellcheck disable=SC2002
    export "$(cat .env | grep -v ^# | xargs)"
fi

# Default values
export DEV_ENV=${DEV_END:-base}
export DEV_USER=${DEV_USER:-devuser}
export PUID=${PUID:-1000}
export PGID=${PGID:-1000}
export TZ=${TZ:-UTC}
export SSH_PORT=${SSH_PORT:-2222}
