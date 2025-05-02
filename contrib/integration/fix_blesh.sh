#!/usr/bin/env bash
# SENTINEL ble.sh Integration Fix
# This script repairs ble.sh integration with SENTINEL
# Implements strong cryptographic techniques for secure shell environment

# Secure function to check and handle errors with HMAC authentication
_sentinel_secure_check() {
    local timestamp=$(date +%s)
    local resource="$1"
    local operation="$2"
    local nonce=$(openssl rand -hex 8)
    local key="${SENTINEL_AUTH_KEY:-$(hostname | openssl dgst -sha256 | cut -d' ' -f2)}"
    local data="${timestamp}:${resource}:${operation}:${nonce}"
    local hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "$key" | cut -d' ' -f2)
    
    # Log operation with HMAC signature for security auditing
    logger -t "SENTINEL" "[$hmac] Performing $operation on $resource" 2>/dev/null || true
    
    # Return signed token for verification if needed
    echo "${data}:${hmac}"
}

# Progress indicator with spinner and secure logging
show_progress() {
    local msg="$1"
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    
    echo -n "$msg "
    
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf "%c" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b"
    done
    
    wait $pid
    local status=$?
    echo ""
    
    return $status
}

echo "SENTINEL ble.sh Integration Fix"
echo "==============================="
echo "This script will repair ble.sh integration with SENTINEL framework."
echo ""

# Check if ble.sh is installed
if [[ ! -f ~/.local/share/blesh/ble.sh ]]; then
    echo "Error: ble.sh not found at ~/.local/share/blesh/ble.sh"
    echo "Would you like to install ble.sh? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "Installing ble.sh..."
        git clone --depth 1 https://github.com/akinomyoga/ble.sh.git /tmp/blesh
        pushd /tmp/blesh > /dev/null
        make install PREFIX=~/.local
        popd > /dev/null
        rm -rf /tmp/blesh
        echo "ble.sh installed successfully"
    else
        echo "Aborted. Please install ble.sh manually."
        exit 1
    fi
fi

# Check and fix permissions
echo "Checking file permissions..."
chmod +x ~/.local/share/blesh/ble.sh
(
    find ~/.local/share/blesh/contrib -type f -name "*.bash" -exec chmod +x {} \; 2>/dev/null
    _sentinel_secure_check "blesh_files" "permission_fix"
) & show_progress "Setting executable permissions for ble.sh files"

# Check required directories
mkdir -p ~/.sentinel/autocomplete/context
mkdir -p ~/.sentinel/autocomplete/params
mkdir -p ~/.sentinel/autocomplete/categories.db

# Fix path_manager.sh
echo "Fixing path_manager.sh..."
if [[ -f ~/Documents/GitHub/SENTINEL/bash_functions.d/path_manager.sh ]]; then
    chmod +x ~/Documents/GitHub/SENTINEL/bash_functions.d/path_manager.sh
    _sentinel_secure_check "path_manager.sh" "permission_fix"
else
    echo "Error: path_manager.sh not found"
fi

# Create integration loader
echo "Creating integration loader..."
cat > ~/.sentinel/blesh_loader.sh << 'EOF'
#!/usr/bin/env bash
# SENTINEL ble.sh integration loader
# This script loads ble.sh with proper error handling

# Try to load ble.sh
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    source ~/.local/share/blesh/ble.sh 2>/dev/null
    if ! type -t ble-bind &>/dev/null; then
        echo "Warning: ble.sh did not load properly. Advanced autocompletion features will be limited."
    else
        # Configure predictive suggestion settings
        bleopt complete_auto_delay=100 2>/dev/null || true
        bleopt complete_auto_complete=1 2>/dev/null || true
        bleopt highlight_auto_completion='fg=242' 2>/dev/null || true
        
        # Configure key bindings
        ble-bind -m auto_complete -f right 'auto_complete/accept-line' 2>/dev/null || true
        
        # FZF integration
        if [[ -f ~/.local/share/blesh/contrib/integration/fzf-initialize.bash ]]; then
            source ~/.local/share/blesh/contrib/integration/fzf-initialize.bash 2>/dev/null || true
        fi
    fi
fi
EOF

chmod +x ~/.sentinel/blesh_loader.sh

# Add to bashrc if not already there
if ! grep -q "~/.sentinel/blesh_loader.sh" ~/.bashrc; then
    echo '# SENTINEL ble.sh integration' >> ~/.bashrc
    echo 'if [[ -f ~/.sentinel/blesh_loader.sh ]]; then' >> ~/.bashrc
    echo '    source ~/.sentinel/blesh_loader.sh' >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
    echo "Added integration loader to ~/.bashrc"
fi

# Test configuration
echo "Testing configuration..."
(
    source ~/.sentinel/blesh_loader.sh
    if type -t ble-bind &>/dev/null; then
        _sentinel_secure_check "blesh" "successful_load"
        exit 0
    else
        _sentinel_secure_check "blesh" "failed_load"
        exit 1
    fi
) > /dev/null

if [ $? -eq 0 ]; then
    echo "ble.sh integration fixed successfully!"
    echo "Please restart your terminal or run 'source ~/.sentinel/blesh_loader.sh'"
else
    echo "Error: ble.sh integration could not be fixed completely."
    echo "Please check the logs for more information."
fi

# Create test token with HMAC for verification
TEST_TOKEN=$(_sentinel_secure_check "fix_blesh.sh" "completion")
echo "Integration verification token: ${TEST_TOKEN}" 