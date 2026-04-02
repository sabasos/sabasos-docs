#!/usr/bin/env bash
# setup-local.sh — Set up and preview sabas-docs on Bluefin OS
# Usage: ./setup-local.sh [build|serve|dev|clean]

set -euo pipefail

COMMAND="${1:-dev}"

# ─── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[sabas-docs]${NC} $*"; }
success() { echo -e "${GREEN}[sabas-docs]${NC} $*"; }
warn()    { echo -e "${YELLOW}[sabas-docs]${NC} $*"; }
error()   { echo -e "${RED}[sabas-docs]${NC} $*"; exit 1; }

# ─── Detect OS ────────────────────────────────────────────────────────────────
detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "${ID:-unknown}"
  else
    echo "unknown"
  fi
}

IS_IMMUTABLE=false
OS_ID=$(detect_os)
if [[ "$OS_ID" == "fedora" ]] && grep -q "ostree\|silverblue\|bluefin\|aurora" /etc/os-release 2>/dev/null; then
  IS_IMMUTABLE=true
fi

# ─── Node.js installation ─────────────────────────────────────────────────────
ensure_node() {
  if command -v node &>/dev/null; then
    NODE_VER=$(node --version)
    success "Node.js already installed: $NODE_VER"
    return
  fi

  info "Node.js not found. Installing..."

  # Bluefin/Aurora: use Homebrew (pre-installed on Bluefin)
  if command -v brew &>/dev/null; then
    info "Installing Node.js via Homebrew (recommended for Bluefin)..."
    brew install node
    success "Node.js installed via Homebrew"

  # Fallback: use toolbox
  elif command -v toolbox &>/dev/null || command -v distrobox &>/dev/null; then
    warn "Homebrew not found. Please run inside a toolbox/distrobox container:"
    echo ""
    echo "  toolbox create sabas-dev"
    echo "  toolbox enter sabas-dev"
    echo "  sudo dnf install -y nodejs npm"
    echo "  cd $(pwd)"
    echo "  ./setup-local.sh"
    echo ""
    exit 1

  # Fallback: mutable system
  elif command -v dnf &>/dev/null; then
    info "Installing Node.js via dnf..."
    sudo dnf install -y nodejs npm
    success "Node.js installed via dnf"

  else
    error "Cannot install Node.js automatically. Please install it manually:\n  https://nodejs.org"
  fi
}

# ─── Verify we're in the right directory ──────────────────────────────────────
if [ ! -f "antora-playbook.yml" ]; then
  error "Run this script from the sabas-docs directory."
fi

# ─── Commands ─────────────────────────────────────────────────────────────────
cmd_install() {
  ensure_node
  if [ ! -d "node_modules" ]; then
    info "Installing dependencies..."
    npm install
    success "Dependencies installed"
  else
    success "Dependencies already installed (run 'npm install' to update)"
  fi
}

cmd_build() {
  cmd_install
  info "Building docs (local playbook)..."
  npx antora --fetch antora-playbook-local.yml
  success "Docs built → build/site/"
}

cmd_serve() {
  if [ ! -d "build/site" ]; then
    warn "No build found. Building first..."
    cmd_build
  fi
  info "Serving docs at http://localhost:3000 ..."
  npx http-server build/site -p 3000 -o
}

cmd_dev() {
  cmd_build
  cmd_serve
}

cmd_clean() {
  info "Cleaning build..."
  rm -rf build/
  success "Cleaned"
}

# ─── Dispatch ─────────────────────────────────────────────────────────────────
case "$COMMAND" in
  install) cmd_install ;;
  build)   cmd_build   ;;
  serve)   cmd_serve   ;;
  dev)     cmd_dev     ;;
  clean)   cmd_clean   ;;
  *)
    echo "Usage: ./setup-local.sh [install|build|serve|dev|clean]"
    echo ""
    echo "  install  — install Node.js and npm dependencies"
    echo "  build    — build the docs site locally"
    echo "  serve    — serve the last build at localhost:3000"
    echo "  dev      — build + serve (default)"
    echo "  clean    — remove build output"
    exit 1
    ;;
esac
