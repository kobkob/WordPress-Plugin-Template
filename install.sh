#!/bin/bash

# WordPress Plugin Template - One-liner Installer
# Usage: curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash
# Or with parameters: curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash -s -- --name "My Plugin" --dir ./my-plugin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Default values
PLUGIN_NAME=""
DESTINATION_DIR=""
INTERACTIVE_MODE=true
REPO_URL="https://github.com/kobkob/WordPress-Plugin-Template.git"
TEMP_DIR=$(mktemp -d)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            PLUGIN_NAME="$2"
            shift 2
            ;;
        --dir)
            DESTINATION_DIR="$2"
            shift 2
            ;;
        --non-interactive)
            INTERACTIVE_MODE=false
            shift
            ;;
        --help|-h)
            print_message $BLUE "WordPress Plugin Template - One-liner Installer"
            echo
            echo "Usage:"
            echo "  curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash"
            echo "  curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash -s -- [OPTIONS]"
            echo
            echo "Options:"
            echo "  --name NAME           Plugin name (e.g., 'My Awesome Plugin')"
            echo "  --dir DIRECTORY       Destination directory"
            echo "  --non-interactive     Skip interactive prompts (requires --name and --dir)"
            echo "  --help, -h           Show this help message"
            echo
            echo "Examples:"
            echo "  # Interactive installation"
            echo "  curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash"
            echo
            echo "  # Non-interactive installation"
            echo "  curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash -s -- --name \"My Plugin\" --dir ./my-plugin --non-interactive"
            echo
            exit 0
            ;;
        *)
            print_message $RED "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

print_message $BLUE "🚀 WordPress Plugin Template - One-liner Installer"
print_message $BLUE "================================================="
echo

# Check for required tools
print_message $YELLOW "Checking dependencies..."
missing_tools=()

if ! command -v git &> /dev/null; then
    missing_tools+=("git")
fi

if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    missing_tools+=("curl or wget")
fi

if [ ${#missing_tools[@]} -ne 0 ]; then
    print_message $RED "Error: Missing required tools: ${missing_tools[*]}"
    print_message $YELLOW "Please install the missing tools and run again"
    exit 1
fi

print_message $GREEN "✓ All dependencies found"
echo

# Clone the repository to temp directory
print_message $YELLOW "Downloading WordPress Plugin Template..."
if ! git clone --quiet "$REPO_URL" "$TEMP_DIR/template"; then
    print_message $RED "Error: Failed to download template from $REPO_URL"
    exit 1
fi

print_message $GREEN "✓ Template downloaded successfully"
echo

# Change to template directory
cd "$TEMP_DIR/template"

# Make create-plugin.sh executable
chmod +x create-plugin.sh

# If non-interactive mode and required parameters are provided
if [[ "$INTERACTIVE_MODE" == false ]]; then
    if [[ -z "$PLUGIN_NAME" || -z "$DESTINATION_DIR" ]]; then
        print_message $RED "Error: Non-interactive mode requires --name and --dir parameters"
        exit 1
    fi
    
    print_message $YELLOW "Creating plugin '$PLUGIN_NAME' in non-interactive mode..."
    
    # Create the destination directory if it doesn't exist
    mkdir -p "$(dirname "$DESTINATION_DIR")"
    
    # Run the creation script with defaults (non-interactive)
    export NAME="$PLUGIN_NAME"
    export FOLDER="$(dirname "$DESTINATION_DIR")"
    export DESCRIPTION="A modern WordPress plugin created from template"
    export AUTHOR="$(git config --global user.name 2>/dev/null || echo 'Plugin Author')"
    export AUTHOR_EMAIL="$(git config --global user.email 2>/dev/null || echo 'author@example.com')"
    export PLUGIN_URI=""
    export GITHUB_ACTIONS="y"
    export PHPUNIT="y"
    export PHPCS="y"
    export FEATURE_API="y"
    export REST_API="y"
    export DOCKER_ENV="y"
    export AGILE_FRAMEWORK="y"
    export NEWREPO="y"
    
    # Create a non-interactive version of the script
    sed -e 's/read -r NAME/NAME="${NAME:-My Plugin}"/' \
        -e 's/read -r FOLDER/FOLDER="${FOLDER:-./my-plugin}"/' \
        -e 's/read -r DESCRIPTION/DESCRIPTION="${DESCRIPTION:-A modern WordPress plugin}"/' \
        -e 's/read -r AUTHOR/AUTHOR="${AUTHOR:-Plugin Author}"/' \
        -e 's/read -r AUTHOR_EMAIL/AUTHOR_EMAIL="${AUTHOR_EMAIL:-author@example.com}"/' \
        -e 's/read -r PLUGIN_URI/PLUGIN_URI="${PLUGIN_URI:-}"/' \
        -e 's/read -r GITHUB_ACTIONS/GITHUB_ACTIONS="${GITHUB_ACTIONS:-y}"/' \
        -e 's/read -r PHPUNIT/PHPUNIT="${PHPUNIT:-y}"/' \
        -e 's/read -r PHPCS/PHPCS="${PHPCS:-y}"/' \
        -e 's/read -r FEATURE_API/FEATURE_API="${FEATURE_API:-y}"/' \
        -e 's/read -r REST_API/REST_API="${REST_API:-y}"/' \
        -e 's/read -r DOCKER_ENV/DOCKER_ENV="${DOCKER_ENV:-y}"/' \
        -e 's/read -r AGILE_FRAMEWORK/AGILE_FRAMEWORK="${AGILE_FRAMEWORK:-y}"/' \
        -e 's/read -r NEWREPO/NEWREPO="${NEWREPO:-y}"/' \
        create-plugin.sh > create-plugin-noninteractive.sh
    
    chmod +x create-plugin-noninteractive.sh
    ./create-plugin-noninteractive.sh
    
else
    # Interactive mode - run the standard creation script
    print_message $YELLOW "Starting interactive plugin creation..."
    echo
    ./create-plugin.sh
fi

print_message $GREEN "✅ WordPress Plugin Template installation completed!"
print_message $BLUE "🎉 Happy coding!"
