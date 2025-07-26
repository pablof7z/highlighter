#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${YELLOW}🔄 Refreshing Xcode project after file changes...${NC}"

# Clean derived data if requested
if [[ "${CLEAN:-false}" == "true" ]]; then
    echo -e "${YELLOW}🧹 Cleaning derived data...${NC}"
    rm -rf .build/DerivedData
fi

# Regenerate project
xcodegen generate --spec project.yml

echo -e "${GREEN}✅ Project refreshed! The .xcodeproj now includes all current files.${NC}"
echo -e "${GREEN}   Code signing is configured from project.yml${NC}"