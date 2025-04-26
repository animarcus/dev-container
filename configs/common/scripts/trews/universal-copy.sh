#!/bin/bash
# universal-copy.sh - A utility for cross-platform clipboard operations
# v0.1.0

# Copy text to clipboard using the best available method
# Usage: universal-copy "text to copy"
universal_copy() {
    local text="$1"
    local success=false

    # Try different clipboard commands based on OS
    if command -v pbcopy >/dev/null 2>&1; then
        # macOS
        echo "$text" | pbcopy
        success=true
    elif command -v xclip >/dev/null 2>&1; then
        # Linux with xclip
        echo "$text" | xclip -selection clipboard
        success=true
    elif command -v xsel >/dev/null 2>&1; then
        # Linux with xsel
        echo "$text" | xsel --clipboard --input
        success=true
    elif command -v wl-copy >/dev/null 2>&1; then
        # Wayland
        echo "$text" | wl-copy
        success=true
    elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$DOCKER_CONTAINER" ]; then
        # SSH session or Docker container - try OSC 52 escape sequence
        encoded=$(echo -n "$text" | base64 | tr -d '\n')
        printf "\033]52;c;%s\a" "$encoded"
        echo "Attempted to copy to clipboard using OSC 52 escape sequence."
        success=true
    fi

    if [ "$success" = true ]; then
        return 0
    else
        echo "No clipboard command found. Please manually copy the output."
        return 1
    fi
}

# If executed directly (not sourced), run with arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ -z "$1" ]; then
        # If no argument is provided, read from stdin
        input=$(cat)
        universal_copy "$input"
    else
        universal_copy "$1"
    fi
fi
