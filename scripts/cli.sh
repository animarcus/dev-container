#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utility functions
# shellcheck disable=SC1091
source "$SCRIPT_DIR/utils/env.sh"

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
    echo "    --rebuild            Rebuild container before starting"
    echo "    --purge             Remove volumes and rebuild everything"
    echo "    --clean-stop        Stop cleanly before starting"
    echo ""
    echo "  stop [flags]          Stop environment"
    echo "    --clean             Remove containers and networks"
    echo ""
    echo "  build [env] [flags]   Build environment"
    echo "    --no-cache          Build without using cache"
    echo "    --base-only         Only build base image"
    echo ""
    echo "  clean                 Remove all containers, volumes, and images"
    echo "  list                  List available environments"
    echo "  shell [env]           Open shell in container"
}

function list_environments() {
    echo "Available environments:"
    for env in "$PROJECT_ROOT/environments"/*; do
        [[ -d "$env" ]] && echo " - $(basename "$env")"
    done
}

function clean_environment() {
    log "Cleaning all Docker resources..."
    docker compose down -v
    docker image rm -f dev-container-base:latest
    docker image rm -f $(docker images -q 'dev-container-*')
}

function stop_environment() {
    local clean=$1
    if [ "$clean" = true ]; then
        log "Stopping and cleaning up..."
        docker compose down
    else
        log "Stopping containers..."
        docker compose stop
    fi
}

function build_environment() {
    local env_name="${1:-base}"
    local no_cache=$2
    local base_only=$3
    
    local cache_flag=""
    if [ "$no_cache" = true ]; then
        cache_flag="--no-cache"
    fi

    # Build base image if needed
    if [ "$env_name" = "base" ] || [ "$base_only" = false ]; then
        log "Building base environment..."
        docker compose --profile build-only build $cache_flag base
    fi

    # Build environment unless base_only is true
    if [ "$base_only" = false ]; then
        log "Building $env_name environment..."
        DEV_ENV="$env_name" docker compose build $cache_flag dev-container
    fi
}

function start_environment() {
    local env_name="${1:-base}"
    local rebuild=$2
    local purge=$3
    local clean_stop=$4

    if [ "$purge" = true ]; then
        clean_environment
        rebuild=true
    elif [ "$clean_stop" = true ]; then
        stop_environment true
    fi

    if [ "$rebuild" = true ]; then
        build_environment "$env_name" false false
    fi

    log "Starting $env_name environment..."
    DEV_ENV="$env_name" docker compose up -d
}

# Parse command line arguments
case "$1" in
    start)
        shift
        env_name="base"
        rebuild=false
        purge=false
        clean_stop=false
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                --rebuild) rebuild=true ;;
                --purge) purge=true ;;
                --clean-stop) clean_stop=true ;;
                *) env_name=$1 ;;
            esac
            shift
        done
        
        start_environment "$env_name" "$rebuild" "$purge" "$clean_stop"
        ;;
    stop)
        clean=false
        [[ "$2" == "--clean" ]] && clean=true
        stop_environment "$clean"
        ;;
    build)
        shift
        env_name="base"
        no_cache=false
        base_only=false
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                --no-cache) no_cache=true ;;
                --base-only) base_only=true ;;
                *) env_name=$1 ;;
            esac
            shift
        done
        
        build_environment "$env_name" "$no_cache" "$base_only"
        ;;
    clean)
        clean_environment
        ;;
    list)
        list_environments
        ;;
    shell)
        env_name="${2:-base}"
        docker exec -it dev-container-"$env_name" /bin/zsh
        ;;
    *)
        show_help
        ;;
esac
