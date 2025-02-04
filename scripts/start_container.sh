#!/bin/bash

# Simple management script for development container
# Usage: ./start_container.sh [start|stop|restart]

# Configuration
COMPOSE_FILE="src/docker-compose.yml"

# Helper function for consistent log formatting
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Main script logic
case "$1" in
    "start")
        log "Stopping any existing containers..."
        docker-compose -f $COMPOSE_FILE down

        log "Building container if needed..."
        docker-compose -f $COMPOSE_FILE build

        log "Starting container..."
        docker-compose -f $COMPOSE_FILE up -d

        log "Container status:"
        docker-compose -f $COMPOSE_FILE ps
        ;;
        
    "stop")
        log "Stopping containers..."
        docker-compose -f $COMPOSE_FILE down
        log "Containers stopped"
        ;;
        
    "restart")
        log "Restarting containers..."
        docker-compose -f $COMPOSE_FILE down
        docker-compose -f $COMPOSE_FILE up -d
        log "Container status:"
        docker-compose -f $COMPOSE_FILE ps
        ;;
        
    *)
        echo "Usage: $0 [start|stop|restart]"
        echo "  start   - Stop existing containers, rebuild if needed, and start"
        echo "  stop    - Stop containers"
        echo "  restart - Restart containers without rebuild"
        exit 1
        ;;
esac
