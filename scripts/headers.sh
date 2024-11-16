script_dir=$(dirname -- "$(readlink -nf $0)";)

#!/bin/zsh

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly GREY='\033[0;90m'
readonly NC='\033[0m' # No Color

# Function to print error message in red
error() {
    echo -e "${RED}[ERROR] $*${NC}" >&2
}

# Function to print success message in green
success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}"
}

# Function to print warning message in yellow
warning() {
    echo -e "${YELLOW}[WARNING] $*${NC}"
}

# Function to print info message in blue
info() {
    echo -e "${BLUE}[INFO] $*${NC}"
}

# Function to print debug message in grey
debug() {
    echo -e "${GREY}[DEBUG] $*${NC}"
}

# Function to print step message in cyan
step() {
    echo -e "${CYAN}[STEP] $*${NC}"
}

# Function to print important message in purple
important() {
    echo -e "${PURPLE}[IMPORTANT] $*${NC}"
}