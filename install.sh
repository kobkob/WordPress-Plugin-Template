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
PLUGIN_DESCRIPTION=""
PLUGIN_AUTHOR=""
PLUGIN_AUTHOR_EMAIL=""
PLUGIN_URI=""
INCLUDE_FEATURE_API="y"
INCLUDE_REST_API="y"
INCLUDE_GITHUB_ACTIONS="y"
INCLUDE_PHPUNIT="y"
INCLUDE_PHPCS="y"
INCLUDE_DOCKER="y"
INCLUDE_AGILE="y"
CREATE_NEW_REPO="y"
INTERACTIVE_MODE=true
REPO_URL="https://github.com/kobkob/WordPress-Plugin-Template.git"
TEMP_DIR=$(mktemp -d)

# Store the original working directory before changing to temp
ORIGINAL_PWD="$PWD"

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
        --description)
            PLUGIN_DESCRIPTION="$2"
            shift 2
            ;;
        --author)
            PLUGIN_AUTHOR="$2"
            shift 2
            ;;
        --author-email)
            PLUGIN_AUTHOR_EMAIL="$2"
            shift 2
            ;;
        --uri)
            PLUGIN_URI="$2"
            shift 2
            ;;
        --include-feature-api)
            INCLUDE_FEATURE_API="$2"
            shift 2
            ;;
        --include-rest-api)
            INCLUDE_REST_API="$2"
            shift 2
            ;;
        --include-github-actions)
            INCLUDE_GITHUB_ACTIONS="$2"
            shift 2
            ;;
        --include-phpunit)
            INCLUDE_PHPUNIT="$2"
            shift 2
            ;;
        --include-phpcs)
            INCLUDE_PHPCS="$2"
            shift 2
            ;;
        --include-docker)
            INCLUDE_DOCKER="$2"
            shift 2
            ;;
        --include-agile)
            INCLUDE_AGILE="$2"
            shift 2
            ;;
        --create-repo)
            CREATE_NEW_REPO="$2"
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
            echo "  --name NAME                      Plugin name (e.g., 'My Awesome Plugin')"
            echo "  --dir DIRECTORY                  Destination directory"
            echo "  --description DESCRIPTION        Plugin description"
            echo "  --author AUTHOR                  Plugin author name"
            echo "  --author-email EMAIL             Plugin author email"
            echo "  --uri URI                        Plugin URI"
            echo "  --include-feature-api VALUE      Include Feature API integration (y/n)"
            echo "  --include-rest-api VALUE         Include REST API endpoints (y/n)"
            echo "  --include-github-actions VALUE   Include GitHub Actions workflows (y/n)"
            echo "  --include-phpunit VALUE          Include PHPUnit tests (y/n)"
            echo "  --include-phpcs VALUE            Include PHPCS configuration (y/n)"
            echo "  --include-docker VALUE           Include Docker development environment (y/n)"
            echo "  --include-agile VALUE            Include Agile development framework (y/n)"
            echo "  --create-repo VALUE              Initialize a new Git repository (y/n)"
            echo "  --non-interactive                Skip interactive prompts (requires --name)"
            echo "  --help, -h                       Show this help message"
            echo
            echo "Examples:"
            echo "  # Interactive installation"
            echo "  curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash"
            echo
            echo "  # Non-interactive installation with all options"
            echo "  curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash -s -- \\"
            echo "      --name \"Test Plugin AI\" \\"
            echo "      --dir ./test-plugin-ai \\"
            echo "      --description \"A test plugin with AI features\" \\"
            echo "      --author \"Test Author\" \\"
            echo "      --include-feature-api y \\"
            echo "      --include-rest-api y \\"
            echo "      --non-interactive"
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

# Function to detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt-get &> /dev/null; then
            echo "debian"
        elif command -v yum &> /dev/null; then
            echo "rhel"
        elif command -v dnf &> /dev/null; then
            echo "fedora"
        elif command -v pacman &> /dev/null; then
            echo "arch"
        elif command -v apk &> /dev/null; then
            echo "alpine"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        # Windows
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to install dependencies based on OS
install_dependencies() {
    local os=$(detect_os)
    local missing_tools=("$@")
    
    if [[ ${#missing_tools[@]} -eq 0 ]]; then
        return 0
    fi
    
    print_message $YELLOW "Installing missing dependencies: ${missing_tools[*]}"
    
    case $os in
        "debian")
            # Ubuntu/Debian
            print_message $YELLOW "Detected Debian/Ubuntu system. Installing dependencies..."
            sudo apt-get update -qq
            for tool in "${missing_tools[@]}"; do
                case $tool in
                    "git") sudo apt-get install -y git ;;
                    "curl") sudo apt-get install -y curl ;;
                    "php") sudo apt-get install -y php-cli php-curl php-zip php-xml php-mbstring ;;
                    "composer")
                        # Install Composer
                        if ! command -v php &> /dev/null; then
                            sudo apt-get install -y php-cli
                        fi
                        curl -sS https://getcomposer.org/installer | php
                        sudo mv composer.phar /usr/local/bin/composer
                        sudo chmod +x /usr/local/bin/composer
                        ;;
                    "node")
                        # Install Node.js via NodeSource repository
                        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                        sudo apt-get install -y nodejs
                        ;;
                    "npm") sudo apt-get install -y npm ;;
                esac
            done
            ;;
        "rhel")
            # RHEL/CentOS
            print_message $YELLOW "Detected RHEL/CentOS system. Installing dependencies..."
            for tool in "${missing_tools[@]}"; do
                case $tool in
                    "git") sudo yum install -y git ;;
                    "curl") sudo yum install -y curl ;;
                    "php") sudo yum install -y php php-cli php-curl php-zip php-xml php-mbstring ;;
                    "composer")
                        if ! command -v php &> /dev/null; then
                            sudo yum install -y php php-cli
                        fi
                        curl -sS https://getcomposer.org/installer | php
                        sudo mv composer.phar /usr/local/bin/composer
                        sudo chmod +x /usr/local/bin/composer
                        ;;
                    "node")
                        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
                        sudo yum install -y nodejs
                        ;;
                    "npm") sudo yum install -y npm ;;
                esac
            done
            ;;
        "fedora")
            # Fedora
            print_message $YELLOW "Detected Fedora system. Installing dependencies..."
            for tool in "${missing_tools[@]}"; do
                case $tool in
                    "git") sudo dnf install -y git ;;
                    "curl") sudo dnf install -y curl ;;
                    "php") sudo dnf install -y php php-cli php-curl php-zip php-xml php-mbstring ;;
                    "composer")
                        if ! command -v php &> /dev/null; then
                            sudo dnf install -y php php-cli
                        fi
                        curl -sS https://getcomposer.org/installer | php
                        sudo mv composer.phar /usr/local/bin/composer
                        sudo chmod +x /usr/local/bin/composer
                        ;;
                    "node")
                        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
                        sudo dnf install -y nodejs npm
                        ;;
                    "npm") sudo dnf install -y npm ;;
                esac
            done
            ;;
        "arch")
            # Arch Linux
            print_message $YELLOW "Detected Arch Linux system. Installing dependencies..."
            for tool in "${missing_tools[@]}"; do
                case $tool in
                    "git") sudo pacman -S --noconfirm git ;;
                    "curl") sudo pacman -S --noconfirm curl ;;
                    "php") sudo pacman -S --noconfirm php php-curl php-zip php-xml ;;
                    "composer") sudo pacman -S --noconfirm composer ;;
                    "node") sudo pacman -S --noconfirm nodejs npm ;;
                    "npm") sudo pacman -S --noconfirm npm ;;
                esac
            done
            ;;
        "alpine")
            # Alpine Linux
            print_message $YELLOW "Detected Alpine Linux system. Installing dependencies..."
            for tool in "${missing_tools[@]}"; do
                case $tool in
                    "git") sudo apk add git ;;
                    "curl") sudo apk add curl ;;
                    "php") sudo apk add php php-cli php-curl php-zip php-xml php-mbstring ;;
                    "composer") sudo apk add composer ;;
                    "node") sudo apk add nodejs npm ;;
                    "npm") sudo apk add npm ;;
                esac
            done
            ;;
        "macos")
            # macOS
            print_message $YELLOW "Detected macOS system. Installing dependencies..."
            if ! command -v brew &> /dev/null; then
                print_message $YELLOW "Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            for tool in "${missing_tools[@]}"; do
                case $tool in
                    "git") brew install git ;;
                    "curl") brew install curl ;;
                    "php") brew install php ;;
                    "composer") brew install composer ;;
                    "node") brew install node ;;
                    "npm") brew install node ;; # npm comes with node
                esac
            done
            ;;
        "windows")
            # Windows (WSL/Git Bash/MSYS2)
            print_message $YELLOW "Detected Windows system."
            print_message $RED "Automatic dependency installation on Windows is not supported."
            print_message $YELLOW "Please install the following tools manually:"
            print_message $YELLOW "- Git: https://git-scm.com/download/win"
            print_message $YELLOW "- PHP: https://windows.php.net/download/"
            print_message $YELLOW "- Composer: https://getcomposer.org/download/"
            print_message $YELLOW "- Node.js: https://nodejs.org/en/download/"
            return 1
            ;;
        *)
            print_message $RED "Unknown operating system. Cannot install dependencies automatically."
            print_message $YELLOW "Please install the following tools manually: ${missing_tools[*]}"
            return 1
            ;;
    esac
    
    return 0
}

# Check for required tools and install them if missing
print_message $YELLOW "Checking dependencies..."
missing_tools=()

# Check for essential tools
if ! command -v git &> /dev/null; then
    missing_tools+=("git")
fi

if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    missing_tools+=("curl")
fi

# Check for development tools (required for full functionality)
if ! command -v php &> /dev/null; then
    missing_tools+=("php")
fi

if ! command -v composer &> /dev/null; then
    missing_tools+=("composer")
fi

if ! command -v node &> /dev/null; then
    missing_tools+=("node")
fi

if ! command -v npm &> /dev/null; then
    missing_tools+=("npm")
fi

if [ ${#missing_tools[@]} -ne 0 ]; then
    print_message $YELLOW "Missing dependencies: ${missing_tools[*]}"
    print_message $YELLOW "Attempting to install dependencies automatically..."
    
    if install_dependencies "${missing_tools[@]}"; then
        print_message $GREEN "✓ Dependencies installed successfully"
        
        # Verify installation
        failed_tools=()
        for tool in "${missing_tools[@]}"; do
            if ! command -v "$tool" &> /dev/null; then
                failed_tools+=("$tool")
            fi
        done
        
        if [ ${#failed_tools[@]} -ne 0 ]; then
            print_message $RED "Error: Failed to install: ${failed_tools[*]}"
            print_message $YELLOW "Please install these tools manually and run again"
            exit 1
        fi
    else
        print_message $RED "Error: Failed to install dependencies automatically"
        print_message $YELLOW "Please install the missing tools manually and run again"
        exit 1
    fi
else
    print_message $GREEN "✓ All dependencies found"
fi
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
    if [[ -z "$PLUGIN_NAME" ]]; then
        print_message $RED "Error: Non-interactive mode requires at least --name parameter"
        exit 1
    fi
    
    # If destination directory not provided, generate one based on plugin name
    if [[ -z "$DESTINATION_DIR" ]]; then
        # Convert plugin name to lowercase, replace spaces with dashes
        DESTINATION_DIR="./$(echo "$PLUGIN_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    fi
    
    # Convert destination to absolute path if it's relative
    if [[ "$DESTINATION_DIR" != /* ]]; then
        DESTINATION_DIR="$ORIGINAL_PWD/$DESTINATION_DIR"
    fi
    
    print_message $YELLOW "Creating plugin '$PLUGIN_NAME' in non-interactive mode..."
    
    # Create the destination directory if it doesn't exist
    mkdir -p "$(dirname "$DESTINATION_DIR")"
    
    # Set environment variables for non-interactive mode
    export NONINTERACTIVE_NAME="$PLUGIN_NAME"
    export NONINTERACTIVE_FOLDER="$DESTINATION_DIR"
    export NONINTERACTIVE_DESCRIPTION="${PLUGIN_DESCRIPTION:-A modern WordPress plugin created from template}"
    export NONINTERACTIVE_AUTHOR="${PLUGIN_AUTHOR:-$(git config --global user.name 2>/dev/null || echo 'Plugin Author')}"
    export NONINTERACTIVE_AUTHOR_EMAIL="${PLUGIN_AUTHOR_EMAIL:-$(git config --global user.email 2>/dev/null || echo 'author@email.com')}"
    export NONINTERACTIVE_PLUGIN_URI="$PLUGIN_URI"
    export NONINTERACTIVE_GITHUB_ACTIONS="$INCLUDE_GITHUB_ACTIONS"
    export NONINTERACTIVE_PHPUNIT="$INCLUDE_PHPUNIT"
    export NONINTERACTIVE_PHPCS="$INCLUDE_PHPCS"
    export NONINTERACTIVE_FEATURE_API="$INCLUDE_FEATURE_API"
    export NONINTERACTIVE_REST_API="$INCLUDE_REST_API"
    export NONINTERACTIVE_DOCKER_ENV="$INCLUDE_DOCKER"
    export NONINTERACTIVE_AGILE_FRAMEWORK="$INCLUDE_AGILE"
    export NONINTERACTIVE_NEWREPO="$CREATE_NEW_REPO"
    
    # Run the create-plugin.sh script directly
    ./create-plugin.sh
    
else
    # Interactive mode - run the standard creation script
    print_message $YELLOW "Starting interactive plugin creation..."
    echo
    print_message $BLUE "Note: Plugin will be created relative to: $ORIGINAL_PWD"
    echo
    ./create-plugin.sh
fi

print_message $GREEN "✅ WordPress Plugin Template installation completed!"
print_message $BLUE "🎉 Happy coding!"
