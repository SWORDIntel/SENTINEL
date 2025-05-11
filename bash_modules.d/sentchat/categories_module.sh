#!/usr/bin/env bash
# SENTINEL Command Categories Module
# Handles command categorization, contextual suggestions, and smart parameters
# This module is part of the SENTINEL autocomplete system
# Version: 1.0.0

# Module information
CATEGORIES_MODULE_VERSION="1.0.0"
CATEGORIES_MODULE_DESCRIPTION="Command categorization and context system for SENTINEL"
CATEGORIES_MODULE_AUTHOR="SENTINEL Team"

# Ensure log directory exists
mkdir -p ~/.sentinel/logs

# Logging functions
_categories_log_error() {
    local msg="$1"
    mkdir -p ~/.sentinel/logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $msg" >> ~/.sentinel/logs/categories-$(date +%Y%m%d).log
}

_categories_log_info() {
    local msg="$1"
    mkdir -p ~/.sentinel/logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $msg" >> ~/.sentinel/logs/categories-$(date +%Y%m%d).log
}

_categories_log_warning() {
    local msg="$1"
    mkdir -p ~/.sentinel/logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $msg" >> ~/.sentinel/logs/categories-$(date +%Y%m%d).log
}

# Initialize directory structure
_sentinel_init_categories_dirs() {
    mkdir -p ~/.sentinel/autocomplete/categories
    mkdir -p ~/.sentinel/autocomplete/context
    mkdir -p ~/.sentinel/autocomplete/params
}
_sentinel_init_categories_dirs

# Command Category Recognition
# Get the category and color for a command
sentinel_get_command_category() {
    local cmd="$1"
    local base_cmd=$(echo "$cmd" | awk '{print $1}')
    
    if [[ -f ~/.sentinel/autocomplete/categories.db ]]; then
        local category=$(grep -E "^$base_cmd\|" ~/.sentinel/autocomplete/categories.db | cut -d'|' -f2)
        local color=$(grep -E "^$base_cmd\|" ~/.sentinel/autocomplete/categories.db | cut -d'|' -f3)
        
        if [[ -n "$category" ]]; then
            echo "$category|$color"
        else
            echo "general|37"  # Default category and color (white)
        fi
    else
        echo "general|37"  # Default category and color (white)
    fi
}

# Add command category to completion hook
sentinel_category_hook() {
    local command_line="${READLINE_LINE:-}"
    if [[ -n "$command_line" ]]; then
        local cat_info=$(sentinel_get_command_category "$command_line")
        local category=$(echo "$cat_info" | cut -d'|' -f1)
        local color=$(echo "$cat_info" | cut -d'|' -f2)
        
        # Set color based on category - requires ble.sh
        if type -t bleopt &>/dev/null; then
            bleopt highlight_auto_completion="fg=$color" 2>/dev/null || true
        fi
    else
        # Reset to default
        if type -t bleopt &>/dev/null; then
            bleopt highlight_auto_completion="fg=242" 2>/dev/null || true
        fi
    fi
}

# Context-Aware Suggestions
sentinel_context_aware_suggest() {
    local command_line="${READLINE_LINE:-}"
    local context_file=~/.sentinel/autocomplete/context/current_context.json
    
    # Update context on each command
    sentinel_update_context
    
    # Read context file if it exists
    if [[ -f "$context_file" ]]; then
        # Extract context information
        local current_dir=$(jq -r '.current_directory' "$context_file" 2>/dev/null)
        local git_repo=$(jq -r '.git_repository // empty' "$context_file" 2>/dev/null)
        local recent_files=$(jq -r '.recent_files[]? // empty' "$context_file" 2>/dev/null)
        
        # Add context-based suggestions to completion candidates if ble.sh is loaded
        if type -t ble-sabbrev &>/dev/null; then
            if [[ -n "$git_repo" && "$command_line" == git* ]]; then
                # Git repository detected, add relevant git commands
                for cmd in "git status" "git pull" "git push" "git commit -m \"\""; do
                    ble-sabbrev "git:${cmd##git }=$cmd" 2>/dev/null || true
                done
            fi
            
            # Directory-specific commands
            if [[ -f "$current_dir/package.json" && "$command_line" == npm* ]]; then
                # Node.js project detected
                for cmd in "npm install" "npm run dev" "npm run build" "npm test"; do
                    ble-sabbrev "npm:${cmd##npm }=$cmd" 2>/dev/null || true
                done
            fi
            
            if [[ -f "$current_dir/requirements.txt" && "$command_line" == pip* ]]; then
                # Python project detected
                ble-sabbrev "pip:install=pip install -r requirements.txt" 2>/dev/null || true
            fi
        fi
    fi
}

# Update current context
sentinel_update_context() {
    local context_file=~/.sentinel/autocomplete/context/current_context.json
    local current_dir=$(pwd)
    
    # Create context object
    {
        echo "{"
        echo "  \"current_directory\": \"$current_dir\","
        
        # Detect git repository
        if git rev-parse --is-inside-work-tree &>/dev/null; then
            echo "  \"git_repository\": \"$(git rev-parse --show-toplevel)\","
            echo "  \"git_branch\": \"$(git branch --show-current)\","
        fi
        
        # Recent files (last 5 files accessed)
        echo "  \"recent_files\": ["
        find "$current_dir" -type f -not -path "*/\.*" -printf "%T@ %p\n" 2>/dev/null | 
            sort -nr | 
            head -5 | 
            awk '{print "    \"" $2 "\","}' | 
            sed '$s/,$//'
        echo "  ]"
        echo "}"
    } > "$context_file"
}

# Smart Parameter Completion
sentinel_smart_param_complete() {
    local command_line="${READLINE_LINE:-}"
    local base_cmd=$(echo "$command_line" | awk '{print $1}')
    local param_file=~/.sentinel/autocomplete/params/$base_cmd.params
    
    # Create parameters directory if it doesn't exist
    mkdir -p ~/.sentinel/autocomplete/params
    
    # If parameter file doesn't exist, create it from history
    if [[ ! -f "$param_file" && -n "$base_cmd" ]]; then
        # Extract most common parameters for this command from history
        HISTTIMEFORMAT="" history | 
            grep "^[0-9]\+ $base_cmd " | 
            awk -v cmd="$base_cmd" '{$1=""; sub(" " cmd " ", ""); print}' | 
            sort | 
            uniq -c | 
            sort -nr | 
            head -10 > "$param_file"
    fi
    
    # If parameter file exists, use it for suggestions if ble.sh is loaded
    if [[ -f "$param_file" && -n "$base_cmd" && -t ble-sabbrev ]]; then
        while read -r count params; do
            if [[ $count -gt 1 ]]; then
                # Add parameter suggestions for this command
                ble-sabbrev "$base_cmd:${params:0:10}=$base_cmd $params" 2>/dev/null || true
            fi
        done < "$param_file"
    fi
}

# Create default command categories database with common commands
sentinel_create_default_categories() {
    _categories_log_info "Creating default command categories database"
    
    cat > ~/.sentinel/autocomplete/categories.db << 'EOF'
# Command category database
# Format: command|category|color
# Version: 2.0.0

# Version control
git|version_control|32
svn|version_control|32
hg|version_control|32

# Container management
docker|container|36
podman|container|36
kubectl|kubernetes|34
helm|kubernetes|34
k3s|kubernetes|34
minikube|kubernetes|34

# Filesystem operations
find|filesystem|33
ls|filesystem|33
cd|filesystem|33
cp|filesystem|33
mv|filesystem|33
rm|filesystem|33
mkdir|filesystem|33
rmdir|filesystem|33
touch|filesystem|33
chmod|filesystem|33
chown|filesystem|33
df|filesystem|33
du|filesystem|33

# File content
cat|filesystem|33
less|filesystem|33
more|filesystem|33
head|filesystem|33
tail|filesystem|33
nano|editor|35
vim|editor|35
vi|editor|35
emacs|editor|35

# Text processing
grep|search|35
awk|text|35
sed|text|35
sort|text|35
uniq|text|35
tr|text|35
cut|text|35
jq|json|36

# Network
ssh|network|31
curl|network|31
wget|network|31
ping|network|31
telnet|network|31
nc|network|31
nmap|network|31
dig|network|31
host|network|31
netstat|network|31
tcpdump|network|31
ip|network|31
ifconfig|network|31

# Package management
apt|package|36
apt-get|package|36
yum|package|36
dnf|package|36
pip|package|36
pip3|package|36
npm|package|36
yarn|package|36
cargo|package|36

# Process management
ps|process|32
top|process|32
htop|process|32
kill|process|31
pkill|process|31

# Security tools
nmap|security|31
openssl|security|31
ssh-keygen|security|31
gpg|security|31
sudo|security|31

# SENTINEL specific
sentinel|sentinel|36
@autocomplete|sentinel|36
EOF

    _categories_log_info "Command categories database created"
}

# Check and repair database files
sentinel_verify_and_repair_categories_db() {
    _categories_log_info "Verifying command categories database"
    
    local db_file=~/.sentinel/autocomplete/categories.db
    
    if [[ -f "$db_file" ]]; then
        # Check for file corruption
        if ! grep -q "^#" "$db_file" && [[ -s "$db_file" ]]; then
            # File exists but header is missing, likely corrupted
            echo "Repairing corrupted database: $db_file"
            _categories_log_warning "Corrupted categories database found, repairing"
            mv "$db_file" "$db_file.corrupted.$(date +%s)" 2>/dev/null
            
            # Recreate the database
            sentinel_create_default_categories
        fi
    else
        # Database does not exist, create it
        _categories_log_info "Categories database not found, creating default"
        sentinel_create_default_categories
    fi
}

# Add command category hooks to BLE.sh if available
sentinel_init_category_hooks() {
    # Verify and initialize the database
    sentinel_verify_and_repair_categories_db
    
    # Register hooks if BLE.sh is loaded
    if type -t blehook &>/dev/null; then
        _categories_log_info "Registering category hooks with BLE.sh"
        
        # Initialize hook with a dummy function if it doesn't exist
        if ! blehook ATTACH_LINE_END 2>/dev/null | grep -q .; then
            blehook ATTACH_LINE_END='true' 2>/dev/null || true
        fi
        
        # Add our hooks
        blehook ATTACH_LINE_END+=sentinel_category_hook 2>/dev/null || true
        blehook ATTACH_LINE_END+=sentinel_context_aware_suggest 2>/dev/null || true
        blehook ATTACH_LINE_END+=sentinel_smart_param_complete 2>/dev/null || true
        
        _categories_log_info "Category hooks registered successfully"
    else
        _categories_log_warning "BLE.sh hooks not available, categorization features limited"
    fi
}

# Status function for categories module
sentinel_categories_status() {
    echo -e "\033[1;32mCommand Categories Status:\033[0m"
    _categories_log_info "Checking categories status"
    
    # Check database
    echo -n "Categories database: "
    if [[ -f ~/.sentinel/autocomplete/categories.db ]]; then
        local count=$(grep -v "^#" ~/.sentinel/autocomplete/categories.db | grep -c "|")
        echo -e "\033[1;32mExists\033[0m ($count entries)"
    else
        echo -e "\033[1;31mMissing\033[0m"
    fi
    
    # Check BLE.sh hooks
    echo -n "BLE.sh hooks: "
    if type -t blehook &>/dev/null; then
        local hooks=$(blehook ATTACH_LINE_END 2>/dev/null | grep -c "sentinel_")
        if [[ $hooks -gt 0 ]]; then
            echo -e "\033[1;32mRegistered\033[0m ($hooks hooks)"
        else
            echo -e "\033[1;33mNot registered\033[0m"
        fi
    else
        echo -e "\033[1;31mBLE.sh not available\033[0m"
    fi
    
    # Check context system
    echo -n "Context system: "
    if [[ -f ~/.sentinel/autocomplete/context/current_context.json ]]; then
        echo -e "\033[1;32mActive\033[0m"
        
        # Show current context summary
        local current_dir=$(jq -r '.current_directory' ~/.sentinel/autocomplete/context/current_context.json 2>/dev/null)
        echo "  Current directory: $current_dir"
        
        local git_repo=$(jq -r '.git_repository // empty' ~/.sentinel/autocomplete/context/current_context.json 2>/dev/null)
        if [[ -n "$git_repo" ]]; then
            local git_branch=$(jq -r '.git_branch // "unknown"' ~/.sentinel/autocomplete/context/current_context.json 2>/dev/null)
            echo "  Git repository: $git_repo ($git_branch)"
        fi
    else
        echo -e "\033[1;31mInactive\033[0m"
    fi
    
    # Check parameter files
    local param_count=$(find ~/.sentinel/autocomplete/params -type f -name "*.params" 2>/dev/null | wc -l)
    echo "Parameter files: $param_count command(s) with saved parameters"
    
    _categories_log_info "Categories status check completed"
}

# Function to fix category database and related files
sentinel_categories_fix() {
    echo "Fixing command categories issues..."
    _categories_log_info "Running categories fix procedure"
    
    # Create necessary directories
    mkdir -p ~/.sentinel/autocomplete/{categories,context,params} 2>/dev/null
    chmod 755 ~/.sentinel/autocomplete/{categories,context,params} 2>/dev/null
    echo "✓ Fixed directory structure"
    
    # Verify and repair database
    sentinel_verify_and_repair_categories_db
    echo "✓ Verified and repaired categories database"
    
    # Update context
    sentinel_update_context
    echo "✓ Updated context information"
    
    # Register hooks if BLE.sh is available
    if type -t blehook &>/dev/null; then
        sentinel_init_category_hooks
        echo "✓ Registered category hooks"
    else
        echo "⚠ BLE.sh not available, hooks not registered"
    fi
    
    echo -e "\nAll categories issues fixed."
    _categories_log_info "Categories fix procedure completed"
}

# Function to add a new category
sentinel_add_category() {
    local command="$1"
    local category="$2"
    local color="$3"
    
    if [[ -z "$command" || -z "$category" ]]; then
        echo "Usage: sentinel_add_category <command> <category> [color]"
        echo "Example: sentinel_add_category python python 34"
        echo "Colors: 31=red, 32=green, 33=yellow, 34=blue, 35=magenta, 36=cyan, 37=white"
        return 1
    fi
    
    # Default color to white if not specified
    [[ -z "$color" ]] && color="37"
    
    # Ensure database exists
    if [[ ! -f ~/.sentinel/autocomplete/categories.db ]]; then
        sentinel_create_default_categories
    fi
    
    # Check if command already exists in database
    if grep -q "^$command|" ~/.sentinel/autocomplete/categories.db; then
        # Update existing entry
        sed -i "s/^$command|.*/$command|$category|$color/" ~/.sentinel/autocomplete/categories.db
        echo "Updated category for '$command' to '$category' with color $color"
    else
        # Add new entry
        echo "$command|$category|$color" >> ~/.sentinel/autocomplete/categories.db
        echo "Added '$command' as category '$category' with color $color"
    fi
    
    _categories_log_info "Added/updated category: $command|$category|$color"
}

# Setup function
sentinel_setup_categories() {
    _categories_log_info "Setting up command categories module"
    
    # Initialize directory structure
    _sentinel_init_categories_dirs
    
    # Verify and initialize database
    sentinel_verify_and_repair_categories_db
    
    # Register hooks if BLE.sh is available
    sentinel_init_category_hooks
    
    # Update context
    sentinel_update_context
    
    # Register with autocomplete manager if available
    if type -t sentinel_autocomplete_register_module &>/dev/null; then
        sentinel_autocomplete_register_module "categories" "$CATEGORIES_MODULE_VERSION" "${BASH_SOURCE[0]}"
    fi
    
    _categories_log_info "Command categories module setup complete"
}

# Export functions for use in other modules
export -f sentinel_get_command_category
export -f sentinel_category_hook
export -f sentinel_context_aware_suggest
export -f sentinel_update_context
export -f sentinel_smart_param_complete
export -f sentinel_add_category
export -f sentinel_categories_status
export -f sentinel_categories_fix

# Run the setup function
sentinel_setup_categories

# Log module loading
_categories_log_info "Command categories module loaded successfully"
echo "SENTINEL Command Categories Module v${CATEGORIES_MODULE_VERSION} loaded" 