#!/bin/bash

echo "🔍 Vivado-on-Mac Setup Verification"
echo "==================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_pass() { echo -e "${GREEN}✅ $1${NC}"; }
check_fail() { echo -e "${RED}❌ $1${NC}"; }
check_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

echo ""
echo "Checking system requirements..."

# Check Docker
if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        check_pass "Docker Desktop is installed and running"
    else
        check_fail "Docker is installed but not running"
        echo "   → Start Docker Desktop application"
    fi
else
    check_fail "Docker Desktop not found"
    echo "   → Install: brew install --cask docker"
fi

# Check XQuartz
if ls /Applications/Utilities/XQuartz.app >/dev/null 2>&1; then
    check_pass "XQuartz is installed"
    if pgrep -x "XQuartz" >/dev/null; then
        check_pass "XQuartz is currently running"
    else
        check_warn "XQuartz is installed but not running"
    fi
else
    check_fail "XQuartz not found"
    echo "   → Install: brew install --cask xquartz"
fi

# Check OpenFPGALoader
if command -v openfpgaloader >/dev/null 2>&1; then
    check_pass "OpenFPGALoader is installed (system)"
elif [[ -x "./openFPGALoader" ]]; then
    check_pass "OpenFPGALoader is available (bundled)"
else
    check_warn "OpenFPGALoader not found"
    echo "   → Install: brew install openfpgaloader (optional, for FPGA programming)"
fi

echo ""
echo "Setup verification complete!"
