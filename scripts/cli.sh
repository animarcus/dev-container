#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="dev-container"

export COMPOSE_BAKE=true

# Source environment variables
if [ -f "$PROJECT_ROOT/.env" ]; then
    # shellcheck disable=SC1091
    source "$PROJECT_ROOT/.env"
fi

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >&2
}

function show_help() {
    echo "Development Environment CLI"
    echo ""
    echo "Usage: ./cli.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start [env] [flags]    Start development environment"
    echo "    --rebuild            Rebuild all containers from scratch (base + env)"
    echo "    --rebuild-env        Rebuild only environment container"
    echo "    --purge             Remove volumes and rebuild everything"
    echo ""
    echo "  stop [flags]          Stop environment"
    echo "    --clean             Remove containers, networks and volumes"
    echo ""
    echo "  build [env] [flags]   Build environment"
    echo "    --no-cache          Build without using cache"
    echo "    --full              Build both base and environment containers"
    echo ""
    echo "  clean                 Remove all containers, volumes, and images"
    echo "  list                  List available environments"
    echo "  shell [env]           Open shell in container"
}

function build_environment() {
    local env_name="${1:-base}"
    local no_cache=$2
    local full_rebuild=$3

    local cache_flag=""
    [[ "$no_cache" == "true" ]] && cache_flag="--no-cache"

    if [[ "$full_rebuild" == "true" ]] || [[ "$env_name" == "base" ]]; then
        log "Building base container..."
        # Use consistent project name
        docker compose -p $PROJECT_NAME --profile build-only build $cache_flag base
        # No need for manual tagging
    fi

    if [[ "$env_name" != "base" ]]; then
        log "Building $env_name environment..."
        # Use same project name
        DEV_ENV="$env_name" docker compose -p $PROJECT_NAME build $cache_flag dev-container
    fi
}

function start_environment() {
    local env_name="${1:-base}"
    local rebuild_all=$2
    local rebuild_env=$3
    local purge=$4

    if [[ "$purge" == "true" ]]; then
        log "Purging all containers and volumes..."
        docker compose -p "$PROJECT_NAME" down -v
        rebuild_all=true
    fi

    if [[ "$rebuild_all" == "true" ]]; then
        log "Performing full rebuild..."
        build_environment "$env_name" "true" "true"
    elif [[ "$rebuild_env" == "true" ]]; then
        log "Rebuilding environment container..."
        build_environment "$env_name" "true" "false"
    fi

    if [[ "$?" -eq 0 ]]; then
        log "Starting $env_name environment..."
        DEV_ENV="$env_name" docker compose -p "$PROJECT_NAME" up -d
    else
        log "Error: Build failed, not starting container"
        return 1
    fi
}

# Parse command line arguments
case "$1" in
start)
    shift
    env_name="base"
    rebuild_all=false
    rebuild_env=false
    purge=false

    while [[ $# -gt 0 ]]; do
        case $1 in
        --rebuild) rebuild_all=true ;;
        --rebuild-env) rebuild_env=true ;;
        --purge) purge=true ;;
        *) env_name=$1 ;;
        esac
        shift
    done

    start_environment "$env_name" "$rebuild_all" "$rebuild_env" "$purge"
    ;;
stop)
    if [[ "$2" == "--clean" ]]; then
        log "Stopping and cleaning up..."
        docker compose -p "$PROJECT_NAME" down -v
    else
        log "Stopping containers..."
        docker compose -p "$PROJECT_NAME" stop
    fi
    ;;
build)
    shift
    env_name="base"
    no_cache=false
    full_rebuild=false

    while [[ $# -gt 0 ]]; do
        case $1 in
        --no-cache) no_cache=true ;;
        --full) full_rebuild=true ;;
        *) env_name=$1 ;;
        esac
        shift
    done

    build_environment "$env_name" "$no_cache" "$full_rebuild"
    ;;
clean)
    log "Cleaning all Docker resources..."
    docker compose -p "$PROJECT_NAME" down -v
    docker image rm -f dev-container-base:latest
    docker image rm -f $(docker images -q 'dev-container-*')
    ;;
list)
    echo "Available environments:"
    for env in "$PROJECT_ROOT/environments"/*; do
        [[ -d "$env" ]] && echo " - $(basename "$env")"
    done
    ;;
shell)
    env_name="${2:-base}"
    docker exec -it dev-container-"$env_name" /bin/zsh
    ;;
*)
    show_help
    ;;
esac
