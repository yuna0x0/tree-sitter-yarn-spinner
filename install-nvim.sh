#!/bin/bash

# Yarn Spinner Tree-sitter Neovim Installation Script
# This script helps install the Yarn Spinner tree-sitter parser for Neovim

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if nvim is installed
check_nvim() {
    if ! command -v nvim &> /dev/null; then
        print_error "Neovim is not installed or not in PATH"
        exit 1
    fi

    # Check Neovim version
    nvim_version=$(nvim --version | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+' | sed 's/v//')
    required_version="0.10"

    if [[ "$(printf '%s\n' "$required_version" "$nvim_version" | sort -V | head -n1)" != "$required_version" ]]; then
        print_error "Neovim version $nvim_version is too old. Requires $required_version or later."
        exit 1
    fi

    print_success "Neovim $nvim_version detected"
}

# Check if nvim-treesitter is installed
check_treesitter() {
    print_info "Checking nvim-treesitter installation..."

    # Try to check if nvim-treesitter is available
    if ! nvim --headless -c "lua require('nvim-treesitter')" -c "quit" 2>/dev/null; then
        print_error "nvim-treesitter is not installed"
        print_info "Please install nvim-treesitter first: https://github.com/nvim-treesitter/nvim-treesitter"
        exit 1
    fi

    print_success "nvim-treesitter is installed"
}

# Get Neovim config directory
get_config_dir() {
    if [[ -n "$XDG_CONFIG_HOME" ]]; then
        NVIM_CONFIG_DIR="$XDG_CONFIG_HOME/nvim"
    else
        NVIM_CONFIG_DIR="$HOME/.config/nvim"
    fi

    if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
        print_warning "Neovim config directory not found: $NVIM_CONFIG_DIR"
        print_info "Creating config directory..."
        mkdir -p "$NVIM_CONFIG_DIR"
    fi

    print_info "Using Neovim config directory: $NVIM_CONFIG_DIR"
}

# Install query files
install_queries() {
    print_info "Installing query files..."

    QUERIES_DIR="$NVIM_CONFIG_DIR/queries/yarn_spinner"
    mkdir -p "$QUERIES_DIR"

    # Copy query files
    for query_file in queries/*.scm; do
        if [[ -f "$query_file" ]]; then
            cp "$query_file" "$QUERIES_DIR/"
            print_success "Copied $(basename "$query_file")"
        fi
    done

    print_success "Query files installed to $QUERIES_DIR"
}

# Generate parser configuration
generate_parser_config() {
    print_info "Generating parser configuration..."

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    cat > /tmp/yarn_spinner_config.lua << EOF
-- Yarn Spinner tree-sitter configuration
-- Add this to your init.lua file

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.yarn_spinner = {
  install_info = {
    url = "$SCRIPT_DIR",
    files = {"src/parser.c", "src/scanner.c"},
    branch = "main",
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = "yarn",
}

-- Register filetype
vim.treesitter.language.register('yarn_spinner', 'yarn')

-- Set up filetype detection
vim.filetype.add({
  extension = {
    yarn = 'yarn',
  },
})

-- Optional: Enable tree-sitter features for Yarn Spinner
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    -- Add yarn_spinner to your existing list
    "yarn_spinner",
  },
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  fold = {
    enable = true,
  },
})

-- Optional: Enable folding for .yarn files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yarn",
  callback = function()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})
EOF

    print_success "Configuration generated at /tmp/yarn_spinner_config.lua"
    print_info "Please add the contents of this file to your init.lua"
}

# Install the parser
install_parser() {
    print_info "Installing parser..."

    # First, we need to make sure the configuration is loaded
    print_info "The parser needs to be installed from within Neovim."
    print_info "After adding the configuration to your init.lua, run:"
    print_info "  :TSInstall yarn_spinner"
}

# Main installation function
main() {
    print_info "Starting Yarn Spinner tree-sitter installation for Neovim..."

    # Check if we're in the right directory
    if [[ ! -f "grammar.js" ]] || [[ ! -d "queries" ]]; then
        print_error "This script must be run from the tree-sitter-yarn-spinner directory"
        exit 1
    fi

    check_nvim
    check_treesitter
    get_config_dir
    install_queries
    generate_parser_config
    install_parser

    print_success "Installation completed!"
    print_info ""
    print_info "Next steps:"
    print_info "1. Add the configuration from /tmp/yarn_spinner_config.lua to your init.lua"
    print_info "2. Restart Neovim"
    print_info "3. Run :TSInstall yarn_spinner"
    print_info "4. Open a .yarn file and enjoy syntax highlighting!"
    print_info ""
    print_info "For more details, see NVIM_SETUP.md"
}

# Show help
show_help() {
    echo "Yarn Spinner Tree-sitter Neovim Installation Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -q, --quiet    Run in quiet mode"
    echo ""
    echo "This script will:"
    echo "  1. Check Neovim and nvim-treesitter installation"
    echo "  2. Install query files to your Neovim config directory"
    echo "  3. Generate parser configuration for your init.lua"
    echo ""
    echo "Run this script from the tree-sitter-yarn-spinner directory."
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -q|--quiet)
            # Redirect output for quiet mode
            exec > /dev/null 2>&1
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main
