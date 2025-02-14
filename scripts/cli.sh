#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utility functions
# shellcheck disable=SC1091
source "$SCRIPT_DIR/utils/env.sh"

function show_help() {
    echo "Development Environment CLI"
    echo ""
    echo "Usage: ./cli.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start <env>    Start development environment"
    echo "  stop           Stop current environment"
    echo "  build <env>    Build environment"
    echo "  list           List available environments"
    echo "  shell          Open shell in container"
}

function list_environments() {
    echo "Available environments:"
    for env in "$PROJECT_ROOT/environments"/*; do
        [[ -d "$env" ]] && echo "  - $(basename "$env")"
    done
}

function build_environment() {
    local env_name="${1:-base}"

    # Always build base first
    if [ "$env_name" != "base" ]; then
        echo "Building base environment..."
        docker-compose build base
    fi

    echo "Building $env_name environment..."
    DEV_ENV="$env_name" docker-compose build dev-container
}

function start_environment() {
    local env_name="${1:-base}"

    # Build first
    build_environment "$env_name"

    # Start container
    DEV_ENV="$env_name" docker-compose up -d
}

case "$1" in
start)
    start_environment "$2"
    ;;
stop)
    docker-compose down
    ;;
build)
    build_environment "$2"
    ;;
list)
    list_environments
    ;;
shell)
    docker exec -it dev-container-"${DEV_ENV:-base}" /bin/zsh
    ;;
*)
    show_help
    ;;
esac
