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

# ─── Node.js installation ─────────────────────────────────────────────────────
# Bluefin OS ships with Homebrew — it is the recommended way to install CLI tools
ensure_node() {
  if command -v node &>/dev/null; then
    success "Node.js already installed: $(node --version)"
    return
  fi

  info "Node.js not found. Installing via Homebrew..."

  if ! command -v brew &>/dev/null; then
    error "Homebrew not found. On Bluefin, open a terminal and run:\n  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\nThen re-run this script."
  fi

  brew install node
  success "Node.js installed: $(node --version)"
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
