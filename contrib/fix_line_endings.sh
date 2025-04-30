#!/usr/bin/env bash
# SENTINEL Line Endings Fix - Bash Script
# Fixes CRLF line endings in Bash files for Linux compatibility

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "===== SENTINEL Line Endings Fix ====="
echo "This script will fix Windows CRLF line endings in Bash files"
echo -e "to ensure they work correctly in Linux environments.${NC}"
echo ""

# Check for dos2unix
if ! command -v dos2unix &> /dev/null; then
    echo -e "${RED}dos2unix is not installed. Attempting to install...${NC}"
    
    # Check package manager and install
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y dos2unix
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y dos2unix
    elif command -v yum &> /dev/null; then
        sudo yum install -y dos2unix
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm dos2unix
    else
        echo -e "${RED}Could not determine package manager. Please install dos2unix manually.${NC}"
        exit 1
    fi
fi

# Check if Python is available as an alternative
if ! command -v dos2unix &> /dev/null; then
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Neither dos2unix nor Python 3 is available. Cannot proceed.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}dos2unix not available, will use Python method instead.${NC}"
    USE_PYTHON=1
else
    USE_PYTHON=0
    echo -e "${GREEN}Using dos2unix for line ending conversion.${NC}"
fi

# Define the root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Find files to process
echo -e "${CYAN}Searching for files to fix...${NC}"

# Function to fix line endings for a single file
fix_file() {
    local file="$1"
    
    # Check if file has CRLF
    if grep -q $'\r' "$file"; then
        echo -e "  ${YELLOW}Fixing:${NC} $file"
        
        # Create backup
        cp "$file" "${file}.bak-winformat"
        
        if [ $USE_PYTHON -eq 1 ]; then
            # Python method
            python3 -c "
import sys
with open('$file', 'rb') as f:
    content = f.read()
with open('$file', 'wb') as f:
    f.write(content.replace(b'\r\n', b'\n'))
"
        else
            # dos2unix method
            dos2unix "$file"
        fi
        
        # Log the fixed file
        echo "$file" >> "bash_line_endings_fix.log"
        return 0
    else
        return 1
    fi
}

# Initialize log file
echo "SENTINEL Line Endings Fix Log" > bash_line_endings_fix.log
echo "Started: $(date)" >> bash_line_endings_fix.log
echo "Root directory: $ROOT_DIR" >> bash_line_endings_fix.log
echo "" >> bash_line_endings_fix.log

# Counter variables
TOTAL_FILES=0
FIXED_FILES=0

# Process bash and shell scripts
echo -e "${CYAN}Processing shell scripts...${NC}"
while IFS= read -r file; do
    TOTAL_FILES=$((TOTAL_FILES + 1))
    if fix_file "$file"; then
        FIXED_FILES=$((FIXED_FILES + 1))
    fi
done < <(find "$ROOT_DIR" -type f \( -name "*.sh" -o -name ".bash*" -o -name "bash_*" -o -path "*/bash_*/*" -o -path "*/.bash_*/*" \) 2>/dev/null)

# Process completion files
echo -e "${CYAN}Processing completion files...${NC}"
while IFS= read -r file; do
    TOTAL_FILES=$((TOTAL_FILES + 1))
    if fix_file "$file"; then
        FIXED_FILES=$((FIXED_FILES + 1))
    fi
done < <(find "$ROOT_DIR" -type f -path "*/bash_completion.d/*" 2>/dev/null)

# Add summary to log
echo "" >> bash_line_endings_fix.log
echo "Summary:" >> bash_line_endings_fix.log
echo "  Total files processed: $TOTAL_FILES" >> bash_line_endings_fix.log
echo "  Files fixed: $FIXED_FILES" >> bash_line_endings_fix.log
echo "Completed: $(date)" >> bash_line_endings_fix.log

# Print summary
echo ""
echo -e "${GREEN}Line endings fix completed:${NC}"
echo -e "  ${CYAN}Total files processed:${NC} $TOTAL_FILES"
echo -e "  ${CYAN}Files fixed:${NC} $FIXED_FILES"
echo ""

if [ $FIXED_FILES -gt 0 ]; then
    echo -e "${GREEN}Files have been fixed. You should now source your bash configuration:${NC}"
    echo -e "  ${CYAN}source ~/.bashrc${NC}"
    echo ""
fi

echo -e "${GREEN}A log file has been created: bash_line_endings_fix.log${NC}"
echo "" 