#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${YELLOW}🔄 Regenerating Xcode project...${NC}"

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo -e "${RED}❌ xcodegen is not installed. Installing via Homebrew...${NC}"
    brew install xcodegen
fi

# Generate Xcode project
xcodegen generate

echo -e "${GREEN}✅ Xcode project regenerated${NC}"

# Build the project
echo -e "${YELLOW}🏗️  Building Highlighter...${NC}"

# Set default values
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 15 Pro}"
CONFIGURATION="${CONFIGURATION:-Debug}"
SCHEME="${SCHEME:-Highlighter}"

# Build with xcbeautify for cleaner output
set -o pipefail && xcodebuild \
    -project Highlighter.xcodeproj \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration "$CONFIGURATION" \
    build \
    | xcbeautify

echo -e "${GREEN}✅ Build completed successfully${NC}"