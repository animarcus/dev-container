#!/bin/bash

# trews.sh - A tree command wrapper with sensible defaults
# v0.5.0

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Source the universal copy utility if it exists
COPY_UTIL="${SCRIPT_DIR}/universal-copy.sh"
if [ -f "$COPY_UTIL" ]; then
    # shellcheck source=/dev/null
    source "$COPY_UTIL"
else
    echo "Warning: universal-copy.sh not found in $SCRIPT_DIR. Clipboard functionality may be limited."
fi

# Predefined default ignore patterns - easily modifiable
DEFAULT_IGNORES=(
    "*pycache*"
    "node_modules"
    "storage"
    "\.vscode"
    "\.idea"
    "\.venv/*"
    "\.git"
    "\.DS_Store*"
)

# Help function
show_help() {
    echo "Usage: trews.sh [OPTIONS] [DIRECTORY] [-- TREE_OPTIONS]"
    echo "A wrapper for the tree command with sensible defaults."
    echo ""
    echo "Options:"
    echo "  -a, --all-dirs      Show hidden directories (like .git) but not their contents"
    echo "  -c, --clipboard     Copy output to clipboard without prompting"
    echo "  -p, --plain         Strip ANSI color codes"
    echo "  -h, --help          Display this help message"
    echo "  -i, --ignore PAT    Add patterns to ignore (pipe-separated)"
    echo "  -n, --no-defaults   Don't use default ignore patterns"
    echo "  -t, --tree-help     Display tree command help"
    echo "  -f, --config FILE   Use specified config file instead of default"
    echo ""
    echo "Configuration:"
    echo "  trews.sh looks for trew-ignore.json in the script directory:"
    echo "  ${SCRIPT_DIR}/trew-ignore.json"
    echo ""
    echo "  The config file supports general_ignores and directory_ignores:"
    echo "  {\"general_ignores\": [\"pattern1\", \"pattern2\"], "
    echo "   \"directory_ignores\": {\"/path/to/dir\": [\"pattern3\"]}}"
    echo ""
    echo "Any options after -- are passed directly to the tree command."
    echo "For more information on tree options, use trews.sh --tree-help"
    exit 0
}

# Show tree help function
show_tree_help() {
    tree --help | less
    exit 0
}

# Copy to clipboard function that runs a clean tree command without display
copy_to_clipboard_pure() {
    local path="$1"
    local tree_cmd="$2"
    local ignores="$3"

    # Create a plain version of the tree command without colors
    local plain_cmd="tree \"$path\""

    # Add ignore patterns if any exist
    if [ -n "$ignores" ]; then
        plain_cmd="$plain_cmd --ignore-case -I '$ignores'"
    fi

    # Add any extra options (minus the color option)
    for opt in "${tree_options[@]}"; do
        if [[ "$opt" != "-C" ]]; then
            plain_cmd="$plain_cmd $opt"
        fi
    done

    # Run the command silently and capture output
    local clipboard_content
    clipboard_content=$(eval "$plain_cmd")

    # Fix the first line with current path
    current_path=$(pwd)
    if [ "$path" != "." ]; then
        if [[ "$path" == /* ]]; then
            # Absolute path
            current_path="$path"
        else
            # Relative path - clean up any double slashes or ../
            current_path=$(realpath "$current_path/$path")
        fi
    fi

    # Replace the first line of output with the current path
    clipboard_content=$(echo "$clipboard_content" | sed "1s:.*:$current_path:")

    # Do the actual clipboard operation
    if type universal_copy >/dev/null 2>&1; then
        # Use the universal copy function from the sourced script
        universal_copy "$clipboard_content"
        echo "✓ Output copied to clipboard!"
    elif command -v pbcopy >/dev/null 2>&1; then
        # macOS pbcopy
        echo "$clipboard_content" | pbcopy
        echo "✓ Output copied to clipboard!"
    elif command -v xclip >/dev/null 2>&1; then
        # Linux xclip
        echo "$clipboard_content" | xclip -selection clipboard
        echo "✓ Output copied to clipboard!"
    elif command -v clip >/dev/null 2>&1; then
        # Windows clip
        echo "$clipboard_content" | clip
        echo "✓ Output copied to clipboard!"
    else
        echo "⚠ Warning: No clipboard utility found. Please ensure universal-copy.sh is properly sourced,"
        echo "  or install pbcopy (macOS), xclip (Linux), or clip (Windows)."
        return 1
    fi

    return 0
}

# Parse command line arguments
copy_to_clipboard=false
use_defaults=true
show_all_dirs=false
strip_colors=false
path="."
additional_cli_ignores=""
tree_options=()
pass_through=false
config_file="${SCRIPT_DIR}/trew-ignore.json"

while [[ $# -gt 0 ]]; do
    # Handle -- for pass-through options
    if [[ "$1" == "--" ]]; then
        pass_through=true
        shift
        break
    fi

    case $1 in
    -a | --all-dirs)
        show_all_dirs=true
        shift
        ;;
    -c | --clipboard)
        copy_to_clipboard=true
        shift
        ;;
    -p | --plain)
        strip_colors=true
        shift
        ;;
    -f | --config)
        config_file="$2"
        shift 2
        ;;
    -h | --help)
        show_help
        ;;
    -i | --ignore)
        additional_cli_ignores="$2"
        shift 2
        ;;
    -n | --no-defaults)
        use_defaults=false
        shift
        ;;
    -t | --tree-help)
        show_tree_help
        ;;
    -* | --*)
        # Store unknown options to pass to tree
        tree_options+=("$1")
        shift
        ;;
    *)
        path="$1"
        shift
        ;;
    esac
done

# Add any remaining arguments as pass-through options
if [ "$pass_through" = true ]; then
    while [[ $# -gt 0 ]]; do
        tree_options+=("$1")
        shift
    done
fi

# Function to get ignores from config file
get_ignores_from_config() {
    local config_file=$1
    local current_path
    current_path="$(cd "$(pwd)" && pwd)"

    local general_ignores=""
    local dir_specific_ignores=""

    if [ -f "$config_file" ] && command -v jq >/dev/null 2>&1; then
        # Get general ignores
        if ! general_ignores=$(jq -r '.general_ignores | join("|")' "$config_file" 2>/dev/null); then
            general_ignores=""
        fi

        # Check if we're in any of the specified directories or their subdirectories
        local dirs
        if ! dirs=$(jq -r '.directory_ignores | keys[]' "$config_file" 2>/dev/null); then
            dirs=""
        fi

        if [ -n "$dirs" ]; then
            while IFS= read -r dir; do
                # Check if current_path starts with dir (or is dir)
                if [[ "$current_path" == "$dir"* ]]; then
                    local dir_patterns
                    if ! dir_patterns=$(jq -r --arg dir "$dir" '.directory_ignores[$dir] | join("|")' "$config_file" 2>/dev/null); then
                        dir_patterns=""
                    fi

                    if [ -n "$dir_patterns" ]; then
                        if [ -n "$dir_specific_ignores" ]; then
                            dir_specific_ignores="${dir_specific_ignores}|${dir_patterns}"
                        else
                            dir_specific_ignores="${dir_patterns}"
                        fi
                        echo "Applied directory-specific ignores for: $dir" >&2
                    fi
                fi
            done <<<"$dirs"
        fi
    fi

    local result=""
    if [ -n "$general_ignores" ]; then
        result="$general_ignores"
    fi

    if [ -n "$dir_specific_ignores" ]; then
        if [ -n "$result" ]; then
            result="${result}|${dir_specific_ignores}"
        else
            result="$dir_specific_ignores"
        fi
    fi

    echo "$result"
}

# Check for config file
config_ignores=""
if [ -f "$config_file" ]; then
    config_ignores=$(get_ignores_from_config "$config_file")
else
    echo "Warning: Config file not found at $config_file" >&2
fi

# Combine ignore patterns
IGNORES=""
if [ "$use_defaults" = true ]; then
    # Convert array to pipe-separated string
    DEFAULT_IGNORES_STR=$(
        IFS="|"
        echo "${DEFAULT_IGNORES[*]}"
    )
    IGNORES="$DEFAULT_IGNORES_STR"
fi

if [ -n "$config_ignores" ]; then
    if [ -n "$IGNORES" ]; then
        IGNORES="$IGNORES|$config_ignores"
    else
        IGNORES="$config_ignores"
    fi
fi

if [ -n "$additional_cli_ignores" ]; then
    if [ -n "$IGNORES" ]; then
        IGNORES="$IGNORES|$additional_cli_ignores"
    else
        IGNORES="$additional_cli_ignores"
    fi
fi

# Determine whether to use color
color_option="-C" # Always use color for output
if [ "$strip_colors" = true ]; then
    color_option="" # Unless explicitly asked not to
fi

# Build tree command with color option set above
tree_cmd="tree \"$path\" $color_option"

# Add ignore patterns if any exist
if [ -n "$IGNORES" ]; then
    tree_cmd="$tree_cmd --ignore-case -I '$IGNORES'"
fi

# Add any additional options
for opt in "${tree_options[@]}"; do
    tree_cmd="$tree_cmd $opt"
done

# Special handling for -a/--all-dirs option
if [ "$show_all_dirs" = true ]; then
    # Run two tree commands: one with ignores, one for hidden dirs only

    # First, get normal tree output with ignores
    normal_cmd="$tree_cmd"
    normal_output=$(eval "$normal_cmd")

    # Replace the first line with current path
    current_path=$(pwd)
    if [ "$path" != "." ]; then
        if [[ "$path" == /* ]]; then
            # Absolute path
            current_path="$path"
        else
            # Relative path - clean up any double slashes or ../
            current_path=$(realpath "$current_path/$path")
        fi
    fi
    normal_output=$(echo "$normal_output" | sed "1s:.*:$current_path:")

    # Now get a simple list of the special directories
    special_dirs=(".git" ".vscode" ".idea")
    for dir in "${special_dirs[@]}"; do
        if [ -d "$path/$dir" ]; then
            # Insert special directory right after the first line
            normal_output=$(echo "$normal_output" | sed "2i\\├── $dir")
        fi
    done

    output="$normal_output"
else
    # Run normal tree command
    command="$tree_cmd"
    output=$(eval "$command")

    # Replace the first line with current path
    current_path=$(pwd)
    if [ "$path" != "." ]; then
        if [[ "$path" == /* ]]; then
            # Absolute path
            current_path="$path"
        else
            # Relative path - clean up any double slashes or ../
            current_path=$(realpath "$current_path/$path")
        fi
    fi

    # Replace the first line of output with the current path
    output=$(echo "$output" | sed "1s:.*:$current_path:")
fi

# If strip colors is requested, remove ANSI color codes
if [ "$strip_colors" = true ]; then
    # Remove ANSI color codes
    output=$(echo "$output" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g")
fi

# Display output
echo "$output"

# Handle clipboard operations
if [ "$copy_to_clipboard" = true ]; then
    # User provided -c flag, copy without prompting
    copy_to_clipboard_pure "$path" "$tree_cmd" "$IGNORES"
else
    # Prompt user if they want to copy to clipboard
    echo ""
    read -p "Copy output to clipboard? (y/n): " copy_choice
    if [[ "$copy_choice" =~ ^[Yy]$ ]]; then
        copy_to_clipboard_pure "$path" "$tree_cmd" "$IGNORES"
    fi
fi
