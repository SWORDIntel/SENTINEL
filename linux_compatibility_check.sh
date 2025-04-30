#!/usr/bin/env bash
# SENTINEL Linux Compatibility Check
# A comprehensive tool to check the codebase for Linux compatibility issues
# Particularly for code that was originally developed on Windows

# Strict error handling
set -eo pipefail

# Terminal colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Command line arguments
NON_INTERACTIVE=0
AUTO_FIX=0

# Process command line arguments
for arg in "$@"; do
    case "$arg" in
        --non-interactive)
            NON_INTERACTIVE=1
            ;;
        --auto-fix)
            AUTO_FIX=1
            NON_INTERACTIVE=1
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --non-interactive    Run without interactive prompts"
            echo "  --auto-fix           Automatically fix issues without prompting"
            echo "  --help               Show this help message"
            exit 0
            ;;
    esac
done

echo -e "${BLUE}=== SENTINEL Linux Compatibility Check ===${NC}"
echo -e "${BLUE}================================================${NC}"

# Create empty arrays for tracking issues
declare -a permission_issues=()
declare -a line_ending_issues=()
declare -a shebang_issues=()
declare -a executable_issues=()
declare -a symlink_issues=()
declare -a encoding_issues=()

# Check if required tools are available
check_requirements() {
    echo -e "\n${BLUE}Checking required tools...${NC}"
    local missing_tools=()
    
    # Check for file utility
    if ! command -v file &> /dev/null; then
        missing_tools+=("file")
    fi
    
    # Check for dos2unix
    if ! command -v dos2unix &> /dev/null; then
        echo -e "${YELLOW}WARNING: dos2unix is not installed. Line ending conversion will be limited.${NC}"
    fi
    
    # Check for grep
    if ! command -v grep &> /dev/null; then
        missing_tools+=("grep")
    fi
    
    # Check for find
    if ! command -v find &> /dev/null; then
        missing_tools+=("find")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}ERROR: Required tools are missing: ${missing_tools[*]}${NC}"
        echo -e "Please install the missing tools before continuing."
        exit 1
    else
        echo -e "${GREEN}All required tools are available.${NC}"
    fi
}

# Check file permissions for scripts
check_permissions() {
    echo -e "\n${BLUE}Checking file permissions...${NC}"
    local script_count=0
    local permission_error_count=0
    
    while IFS= read -r -d '' file; do
        script_count=$((script_count + 1))
        
        # Check if file has execution permissions
        if [[ ! -x "$file" ]]; then
            permission_issues+=("$file")
            permission_error_count=$((permission_error_count + 1))
            echo -e "${YELLOW}WARNING: Script missing executable permissions: ${file}${NC}"
        fi
    done < <(find . -type f -name "*.sh" -print0)
    
    # Check bash configuration files
    while IFS= read -r -d '' file; do
        # For bash config files, check if they have 600 permissions
        perms=$(stat -c "%a" "$file")
        if [[ "$perms" != "600" ]]; then
            permission_issues+=("$file")
            permission_error_count=$((permission_error_count + 1))
            echo -e "${YELLOW}WARNING: Bash config file has insecure permissions: ${file} (${perms})${NC}"
        fi
    done < <(find . -type f \( -name ".bash*" -o -name "bash*" -o -name ".bash_*" -o -name "bash_*" \) -not -path "*/\.*" -not -name "*.sh" -print0)
    
    # Summary
    if [ $permission_error_count -eq 0 ]; then
        echo -e "${GREEN}All script permissions look good.${NC}"
    else
        echo -e "${YELLOW}Found $permission_error_count permission issues in $script_count scripts.${NC}"
    fi
}

# Check for line ending issues (CRLF vs. LF)
check_line_endings() {
    echo -e "\n${BLUE}Checking line endings...${NC}"
    local file_count=0
    local line_ending_error_count=0
    
    # Files that should have Unix line endings
    while IFS= read -r -d '' file; do
        file_count=$((file_count + 1))
        
        # Check if file has CRLF line endings
        if file "$file" | grep -q "CRLF"; then
            line_ending_issues+=("$file")
            line_ending_error_count=$((line_ending_error_count + 1))
            echo -e "${YELLOW}WARNING: File has Windows line endings: ${file}${NC}"
        fi
    done < <(find . -type f \( -name "*.sh" -o -name ".bash*" -o -name "bash*" -o -name ".bash_*" -o -name "bash_*" \) -not -path "*/\.*" -print0)
    
    # Summary
    if [ $line_ending_error_count -eq 0 ]; then
        echo -e "${GREEN}All script files have correct Unix line endings.${NC}"
    else
        echo -e "${YELLOW}Found $line_ending_error_count files with Windows line endings out of $file_count files.${NC}"
    fi
}

# Check for proper shebang lines
check_shebangs() {
    echo -e "\n${BLUE}Checking script shebangs...${NC}"
    local script_count=0
    local shebang_error_count=0
    
    while IFS= read -r -d '' file; do
        script_count=$((script_count + 1))
        
        # Check if first line is a proper shebang
        local first_line
        first_line=$(head -n 1 "$file")
        
        if [[ ! "$first_line" =~ ^#! ]]; then
            shebang_issues+=("$file")
            shebang_error_count=$((shebang_error_count + 1))
            echo -e "${YELLOW}WARNING: Script missing shebang: ${file}${NC}"
        elif [[ "$first_line" =~ /bin/sh ]]; then
            # /bin/sh might behave differently on different systems, recommend /bin/bash if bash-specific features are used
            if grep -q "\[\[" "$file" || grep -q "function " "$file" || grep -q "declare -" "$file"; then
                echo -e "${YELLOW}WARNING: Script uses /bin/sh but appears to use Bash features: ${file}${NC}"
                shebang_issues+=("$file")
                shebang_error_count=$((shebang_error_count + 1))
            fi
        fi
    done < <(find . -type f -name "*.sh" -print0)
    
    # Summary
    if [ $shebang_error_count -eq 0 ]; then
        echo -e "${GREEN}All script shebangs look good.${NC}"
    else
        echo -e "${YELLOW}Found $shebang_error_count shebang issues in $script_count scripts.${NC}"
    fi
}

# Check for broken symbolic links
check_symlinks() {
    echo -e "\n${BLUE}Checking for broken symbolic links...${NC}"
    local broken_links=0
    
    while IFS= read -r -d '' file; do
        if [[ ! -e "$file" ]]; then
            symlink_issues+=("$file -> $(readlink "$file")")
            broken_links=$((broken_links + 1))
            echo -e "${YELLOW}WARNING: Broken symbolic link: ${file} -> $(readlink "$file")${NC}"
        fi
    done < <(find . -type l -print0)
    
    # Summary
    if [ $broken_links -eq 0 ]; then
        echo -e "${GREEN}No broken symbolic links found.${NC}"
    else
        echo -e "${YELLOW}Found $broken_links broken symbolic links.${NC}"
    fi
}

# Check for encoding issues (non-UTF-8 or non-ASCII files)
check_encoding() {
    echo -e "\n${BLUE}Checking file encoding...${NC}"
    local file_count=0
    local encoding_error_count=0
    
    while IFS= read -r -d '' file; do
        file_count=$((file_count + 1))
        
        # Check if file is ASCII or UTF-8
        if file -i "$file" | grep -qv "charset=utf-8\|charset=us-ascii\|charset=binary"; then
            encoding_issues+=("$file")
            encoding_error_count=$((encoding_error_count + 1))
            echo -e "${YELLOW}WARNING: File has non-UTF-8/ASCII encoding: ${file}${NC}"
        fi
    done < <(find . -type f \( -name "*.sh" -o -name ".bash*" -o -name "bash*" -o -name ".bash_*" -o -name "bash_*" \) -not -path "*/\.*" -print0)
    
    # Summary
    if [ $encoding_error_count -eq 0 ]; then
        echo -e "${GREEN}All files have proper encoding (UTF-8 or ASCII).${NC}"
    else
        echo -e "${YELLOW}Found $encoding_error_count files with encoding issues out of $file_count files.${NC}"
    fi
}

# Check module file executability
check_modules() {
    echo -e "\n${BLUE}Checking module executability...${NC}"
    local module_count=0
    local module_error_count=0
    
    # Check if module directory exists
    if [[ -d "./bash_modules.d" ]]; then
        while IFS= read -r -d '' file; do
            module_count=$((module_count + 1))
            
            # Check if module is executable
            if [[ ! -x "$file" ]]; then
                executable_issues+=("$file")
                module_error_count=$((module_error_count + 1))
                echo -e "${YELLOW}WARNING: Module not executable: ${file}${NC}"
            fi
        done < <(find ./bash_modules.d -type f -print0)
        
        # Summary
        if [ $module_error_count -eq 0 ]; then
            echo -e "${GREEN}All modules are properly executable.${NC}"
        else
            echo -e "${YELLOW}Found $module_error_count non-executable modules out of $module_count modules.${NC}"
        fi
    else
        echo -e "${YELLOW}Module directory (bash_modules.d) not found.${NC}"
    fi
}

# Fix identified issues (if confirmed by user)
fix_issues() {
    echo -e "\n${BLUE}Preparing to fix identified issues...${NC}"
    
    # Fix permissions
    if [ ${#permission_issues[@]} -ne 0 ] || [ ${#executable_issues[@]} -ne 0 ]; then
        echo -e "\n${BLUE}Fixing permission issues:${NC}"
        
        # Non-interactive mode handling
        if [ $NON_INTERACTIVE -eq 1 ]; then
            fix_perms="y"
        else
            read -p "Do you want to fix permission issues? (y/n): " fix_perms
        fi
        
        if [[ "$fix_perms" =~ ^[Yy]$ ]]; then
            # Fix script permissions
            for file in "${permission_issues[@]}"; do
                if [[ -f "$file" ]]; then
                    if [[ "$file" == *".sh" ]]; then
                        chmod +x "$file"
                        echo -e "${GREEN}Fixed permissions for script: ${file}${NC}"
                    else
                        chmod 600 "$file"
                        echo -e "${GREEN}Fixed permissions for config file: ${file}${NC}"
                    fi
                fi
            done
            
            # Fix module permissions
            for file in "${executable_issues[@]}"; do
                if [[ -f "$file" ]]; then
                    chmod +x "$file"
                    echo -e "${GREEN}Fixed permissions for module: ${file}${NC}"
                fi
            done
        fi
    fi
    
    # Fix line endings
    if [ ${#line_ending_issues[@]} -ne 0 ]; then
        echo -e "\n${BLUE}Fixing line ending issues:${NC}"
        
        # Non-interactive mode handling
        if [ $NON_INTERACTIVE -eq 1 ]; then
            fix_endings="y"
        else
            read -p "Do you want to fix line ending issues? (y/n): " fix_endings
        fi
        
        if [[ "$fix_endings" =~ ^[Yy]$ ]]; then
            if command -v dos2unix &> /dev/null; then
                for file in "${line_ending_issues[@]}"; do
                    if [[ -f "$file" ]]; then
                        dos2unix "$file"
                        echo -e "${GREEN}Fixed line endings for: ${file}${NC}"
                    fi
                done
            else
                echo -e "${YELLOW}dos2unix not available. Using sed as fallback.${NC}"
                for file in "${line_ending_issues[@]}"; do
                    if [[ -f "$file" ]]; then
                        sed -i 's/\r$//' "$file"
                        echo -e "${GREEN}Fixed line endings for: ${file}${NC}"
                    fi
                done
            fi
        fi
    fi
    
    # Fix shebang issues
    if [ ${#shebang_issues[@]} -ne 0 ]; then
        echo -e "\n${BLUE}Fixing shebang issues:${NC}"
        
        # Non-interactive mode handling
        if [ $NON_INTERACTIVE -eq 1 ]; then
            fix_shebangs="y"
        else
            read -p "Do you want to fix shebang issues? (y/n): " fix_shebangs
        fi
        
        if [[ "$fix_shebangs" =~ ^[Yy]$ ]]; then
            for file in "${shebang_issues[@]}"; do
                if [[ -f "$file" ]]; then
                    # Check if first line is a shebang
                    local first_line
                    first_line=$(head -n 1 "$file")
                    
                    if [[ ! "$first_line" =~ ^#! ]]; then
                        # Add shebang
                        sed -i '1s/^/#!/usr/bin/env bash\n/' "$file"
                        echo -e "${GREEN}Added shebang to: ${file}${NC}"
                    elif [[ "$first_line" =~ /bin/sh ]] && (grep -q "\[\[" "$file" || grep -q "function " "$file" || grep -q "declare -" "$file"); then
                        # Replace /bin/sh with /usr/bin/env bash
                        sed -i '1s|^#!.*|#!/usr/bin/env bash|' "$file"
                        echo -e "${GREEN}Updated shebang in: ${file}${NC}"
                    fi
                fi
            done
        fi
    fi
}

# Run all checks
run_checks() {
    check_requirements
    check_permissions
    check_line_endings
    check_shebangs
    check_symlinks
    check_encoding
    check_modules
}

# Print summary of findings
print_summary() {
    echo -e "\n${BLUE}=== COMPATIBILITY CHECK SUMMARY ===${NC}"
    
    local total_issues=$((${#permission_issues[@]} + ${#line_ending_issues[@]} + ${#shebang_issues[@]} + ${#executable_issues[@]} + ${#symlink_issues[@]} + ${#encoding_issues[@]}))
    
    if [ $total_issues -eq 0 ]; then
        echo -e "${GREEN}Congratulations! No compatibility issues found.${NC}"
    else
        echo -e "${YELLOW}Total issues found: $total_issues${NC}"
        echo -e "Permission issues: ${#permission_issues[@]}"
        echo -e "Line ending issues: ${#line_ending_issues[@]}"
        echo -e "Shebang issues: ${#shebang_issues[@]}"
        echo -e "Module executable issues: ${#executable_issues[@]}"
        echo -e "Broken symlink issues: ${#symlink_issues[@]}"
        echo -e "Encoding issues: ${#encoding_issues[@]}"
        
        # In non-interactive mode, fix issues if auto-fix is enabled
        if [ $NON_INTERACTIVE -eq 1 ]; then
            if [ $AUTO_FIX -eq 1 ]; then
                fix_issues
                echo -e "\n${GREEN}Fix attempt completed. Please run the script again to check if issues remain.${NC}"
            else
                echo -e "\n${YELLOW}Non-interactive mode selected. No changes made.${NC}"
                echo -e "Run with --auto-fix flag to automatically fix issues."
            fi
        else
            # Ask if user wants to fix issues
            read -p "Do you want to attempt to fix these issues? (y/n): " fix_all
            
            if [[ "$fix_all" =~ ^[Yy]$ ]]; then
                fix_issues
                echo -e "\n${GREEN}Fix attempt completed. Please run the script again to check if issues remain.${NC}"
            else
                echo -e "\n${YELLOW}No changes made. You can run this script again to fix issues later.${NC}"
            fi
        fi
    fi
}

# Main function
main() {
    run_checks
    print_summary
}

# Run the script
main 