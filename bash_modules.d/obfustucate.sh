#!/usr/bin/env bash
# SENTINEL Module: obfuscate
# File obfuscation techniques for evading signature-based detection

# Module metadata
SENTINEL_MODULE_VERSION="1.0.0"
SENTINEL_MODULE_DESCRIPTION="File obfuscation utilities for security testing and malware analysis"
SENTINEL_MODULE_AUTHOR="John"
SENTINEL_MODULE_DEPENDENCIES=""

# Check if we're being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be sourced, not executed directly."
    exit 1
fi

# Display initial message with warning
echo -e "${RED}[!] WARNING: Obfuscation module loaded${NC}"
echo -e "${YELLOW}These tools are for legitimate security testing and educational purposes only.${NC}"
echo -e "${YELLOW}Improper use may violate laws and organizational policies.${NC}"
echo -e "${GREEN}Type 'obfuscate_help' for usage information.${NC}"

# Configuration
OBFUSCATE_TEMP_DIR="${OBFUSCATE_TEMP_DIR:-/tmp/obfuscate_temp}"
OBFUSCATE_OUTPUT_DIR="${OBFUSCATE_OUTPUT_DIR:-${HOME}/obfuscated_files}"

# Create necessary directories
mkdir -p "$OBFUSCATE_TEMP_DIR" 2>/dev/null
mkdir -p "$OBFUSCATE_OUTPUT_DIR" 2>/dev/null

# Clean up temp files on exit
trap 'rm -rf "${OBFUSCATE_TEMP_DIR:-/tmp/obfuscate_temp}/"*' EXIT

# Help function
obfuscate_help() {
    cat << EOF
${GREEN}SENTINEL Obfuscation Module Help${NC}
===============================

${YELLOW}WARNING:${NC} These tools are for legitimate security testing and educational 
purposes only. Improper use may violate laws and organizational policies.

${BLUE}General Commands:${NC}
  obfuscate_help              - Show this help message
  obfuscate_check_tools       - Check if required tools are installed

${BLUE}Text Obfuscation:${NC}
  obfuscate_string <string>   - Various string obfuscation techniques
  obfuscate_base64 <string>   - Base64 encode with optional layers
  obfuscate_hex <string>      - Convert to hex representation
  obfuscate_url <string>      - URL-encode a string

${BLUE}Script Obfuscation:${NC}
  obfuscate_bash <file>       - Obfuscate a bash script
  obfuscate_powershell <file> - Obfuscate a PowerShell script
  obfuscate_python <file>     - Obfuscate a Python script
  obfuscate_js <file>         - Obfuscate a JavaScript file

${BLUE}Binary Obfuscation:${NC}
  obfuscate_pe <file>         - Obfuscate a Windows PE file (.exe, .dll)
  obfuscate_elf <file>        - Obfuscate a Linux ELF binary
  obfuscate_macho <file>      - Obfuscate a macOS Mach-O binary
  
${BLUE}Advanced Techniques:${NC}
  obfuscate_split <file>      - Split a file into multiple chunks
  obfuscate_hide <file> <carrier> - Hide a file within another file
  obfuscate_compress <file>   - Custom compression with obfuscated headers

${BLUE}Example Usage:${NC}
  obfuscate_string "malicious.exe"
  obfuscate_bash script.sh
  obfuscate_pe malware_sample.exe
  obfuscate_split large_binary.bin

${YELLOW}Output files are saved to:${NC} $OBFUSCATE_OUTPUT_DIR
EOF
}

# Check if required tools are installed
obfuscate_check_tools() {
    local missing_tools=()
    
    # Essential tools
    for tool in xxd base64 hexdump sed awk tr file; do
        if ! command -v $tool &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    # Optional tools with specific functionality
    echo -e "${BLUE}Checking obfuscation tools...${NC}"
    
    # Check for string manipulation tools
    echo -ne "Core utilities: "
    if (( ${#missing_tools[@]} > 0 )); then
        echo -e "${RED}Missing: ${missing_tools[*]}${NC}"
    else
        echo -e "${GREEN}OK${NC}"
    fi
    
    # Check for PE manipulation tools
    echo -ne "PE manipulation: "
    if command -v upx &>/dev/null; then
        echo -e "${GREEN}UPX found${NC}"
    else
        echo -e "${YELLOW}UPX not found (needed for PE obfuscation)${NC}"
    fi
    
    # Check for script obfuscation tools
    echo -ne "Script obfuscation: "
    local script_tools=0
    if command -v nodejs &>/dev/null || command -v node &>/dev/null; then
        echo -ne "${GREEN}Node.js${NC} "
        script_tools=$((script_tools + 1))
    fi
    if command -v python3 &>/dev/null; then
        echo -ne "${GREEN}Python${NC} "
        script_tools=$((script_tools + 1))
    fi
    if (( script_tools == 0 )); then
        echo -e "${YELLOW}No script obfuscation tools found${NC}"
    else
        echo ""
    fi
    
    # Installation advice if needed
    if (( ${#missing_tools[@]} > 0 )) || ! command -v upx &>/dev/null; then
        echo -e "\n${YELLOW}Install missing tools with:${NC}"
        echo "   sudo apt-get install coreutils xxd bsdmainutils upx-ucl"
    fi
}

# String obfuscation techniques
obfuscate_string() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Usage: obfuscate_string <string>"
        return 1
    fi
    
    echo -e "${GREEN}String Obfuscation Results:${NC}"
    echo -e "${BLUE}Original:${NC} $input"
    
    # Base64
    local b64=$(echo -n "$input" | base64)
    echo -e "${BLUE}Base64:${NC} $b64"
    
    # Hex 
    local hex=$(echo -n "$input" | xxd -p | tr -d '\n')
    echo -e "${BLUE}Hex:${NC} $hex"
    
    # URL encoding
    local url=""
    for (( i=0; i<${#input}; i++ )); do
        local c="${input:$i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) url+="$c" ;;
            *) url+="%$(echo -n "$c" | xxd -p | tr '[:lower:]' '[:upper:]')" ;;
        esac
    done
    echo -e "${BLUE}URL encoded:${NC} $url"
    
    # Reversed
    local reversed=$(echo "$input" | rev)
    echo -e "${BLUE}Reversed:${NC} $reversed"
    
    # Character code array (decimal)
    local char_array="["
    for (( i=0; i<${#input}; i++ )); do
        local c="${input:$i:1}"
        char_array+=$(printf "%d," "'$c")
    done
    char_array="${char_array%,}]"
    echo -e "${BLUE}Char array (dec):${NC} $char_array"
    
    # Character code array (hex)
    local char_array_hex="["
    for (( i=0; i<${#input}; i++ )); do
        local c="${input:$i:1}"
        char_array_hex+=$(printf "0x%x," "'$c")
    done
    char_array_hex="${char_array_hex%,}]"
    echo -e "${BLUE}Char array (hex):${NC} $char_array_hex"
    
    # Split with delimiters (useful for bypassing string detections)
    local split=""
    for (( i=0; i<${#input}; i++ )); do
        local c="${input:$i:1}"
        split+="$c"
        [[ $i -lt $((${#input} - 1)) ]] && split+="+"
    done
    echo -e "${BLUE}Split format:${NC} $split"
    
    # Multi-encoding (base64 of hex)
    local multi=$(echo -n "$hex" | base64)
    echo -e "${BLUE}Multi-encoded:${NC} $multi"
    
    echo -e "\n${YELLOW}Usage examples:${NC}"
    echo -e "  ${CYAN}PowerShell:${NC}"
    echo "    \$str = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$b64'))"
    echo "    \$str = -join($char_array_hex | ForEach-Object {[char]\$_})"
    echo -e "  ${CYAN}Bash:${NC}"
    echo "    str=\$(echo -n '$b64' | base64 -d)"
    echo "    str=\$(echo -n '$hex' | xxd -p -r)"
    echo -e "  ${CYAN}Python:${NC}"
    echo "    import base64; s = base64.b64decode('$b64').decode()"
    echo "    s = bytes.fromhex('$hex').decode()"
    echo "    s = ''.join(chr(c) for c in $char_array)"
    echo -e "  ${CYAN}JavaScript:${NC}"
    echo "    let str = atob('$b64');"
    echo "    let str = String.fromCharCode(...$char_array);"
}

# Base64 obfuscation with layers
obfuscate_base64() {
    local input="$1"
    local layers="${2:-1}"
    
    if [[ -z "$input" ]]; then
        echo "Usage: obfuscate_base64 <string> [layers]"
        return 1
    fi
    
    # Validate layers
    if ! [[ "$layers" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Layers must be a positive integer"
        return 1
    fi
    
    local result="$input"
    local encoded=""
    
    echo -e "${BLUE}Applying $layers layers of Base64 encoding:${NC}"
    echo -e "${BLUE}Original:${NC} $input"
    
    # Apply requested layers of encoding
    for ((i=1; i<=layers; i++)); do
        encoded=$(echo -n "$result" | base64 | tr -d '\n')
        echo -e "${BLUE}Layer $i:${NC} $encoded"
        result="$encoded"
    done
    
    # Generate decoding script
    local output_file="$OBFUSCATE_OUTPUT_DIR/base64_decode_$(date +%Y%m%d%H%M%S).sh"
    
    # Create bash decoder script
    cat > "$output_file" << EOF
#!/bin/bash
# Base64 decoder script for $layers layers
# Generated by SENTINEL Obfuscation Module

input='$encoded'

# Decode $layers layers of Base64
result="\$input"
for ((i=1; i<=$layers; i++)); do
    result=\$(echo -n "\$result" | base64 -d)
    echo "Layer \$i decoded"
done

echo "Final result: \$result"
EOF
    
    chmod +x "$output_file"
    echo -e "\n${GREEN}Bash decoder script created:${NC} $output_file"
    
    # Create PowerShell decoder
    local ps_file="$OBFUSCATE_OUTPUT_DIR/base64_decode_$(date +%Y%m%d%H%M%S).ps1"
    
    cat > "$ps_file" << EOF
# Base64 decoder script for $layers layers
# Generated by SENTINEL Obfuscation Module

\$input = '$encoded'

# Decode $layers layers of Base64
\$result = \$input
for (\$i = 1; \$i -le $layers; \$i++) {
    \$result = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(\$result))
    Write-Host "Layer \$i decoded"
}

Write-Host "Final result: \$result"
EOF
    
    echo -e "${GREEN}PowerShell decoder script created:${NC} $ps_file"
    return 0
}

# Hex encoding
obfuscate_hex() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Usage: obfuscate_hex <string>"
        return 1
    fi
    
    # Convert to hex
    local hex=$(echo -n "$input" | xxd -p | tr -d '\n')
    
    echo -e "${GREEN}Hex Encoding Result:${NC}"
    echo -e "${BLUE}Original:${NC} $input"
    echo -e "${BLUE}Hex:${NC} $hex"
    
    # Generate different formats
    echo -e "\n${BLUE}Different Formats:${NC}"
    
    # Format with 0x prefix per byte
    local hex_0x=$(echo -n "$input" | hexdump -ve '1/1 "0x%02x "')
    echo -e "${CYAN}C-style bytes:${NC} $hex_0x"
    
    # Format as \x escaped string
    local hex_escaped=$(echo -n "$input" | xxd -p | sed 's/\(..\)/\\x\1/g')
    echo -e "${CYAN}Escaped string:${NC} \"$hex_escaped\""
    
    # Format as HTML hex entities
    local html_hex=""
    for (( i=0; i<${#input}; i++ )); do
        local c="${input:$i:1}"
        html_hex+=$(printf "&#x%x;" "'$c")
    done
    echo -e "${CYAN}HTML hex entities:${NC} $html_hex"
    
    # Generate decoders
    echo -e "\n${BLUE}Decode commands:${NC}"
    echo -e "${CYAN}Bash:${NC} echo -n \"$hex\" | xxd -r -p"
    echo -e "${CYAN}Python:${NC} bytes.fromhex('$hex').decode()"
    echo -e "${CYAN}PowerShell:${NC} [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromHexString('$hex'))"
    echo -e "${CYAN}JavaScript:${NC} decodeURIComponent(Array.from(\"$hex\").map((h, i) => i % 2 ? '%' + h + Array.from(\"$hex\")[i-1] : '').join(''))"
    echo -e "${CYAN}Ruby:${NC} [\"$hex\"].pack('H*')"
}

# URL encoding
obfuscate_url() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Usage: obfuscate_url <string>"
        return 1
    fi
    
    # Perform URL encoding
    local url=""
    for (( i=0; i<${#input}; i++ )); do
        local c="${input:$i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) url+="$c" ;;
            *) url+="%$(echo -n "$c" | xxd -p | tr '[:lower:]' '[:upper:]')" ;;
        esac
    done
    
    # Double URL encoding (sometimes helps bypass filters)
    local double_url=""
    for (( i=0; i<${#url}; i++ )); do
        local c="${url:$i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) double_url+="$c" ;;
            *) double_url+="%$(echo -n "$c" | xxd -p | tr '[:lower:]' '[:upper:]')" ;;
        esac
    done
    
    echo -e "${GREEN}URL Encoding Results:${NC}"
    echo -e "${BLUE}Original:${NC} $input"
    echo -e "${BLUE}URL Encoded:${NC} $url"
    echo -e "${BLUE}Double URL Encoded:${NC} $double_url"
    
    # Output decode commands
    echo -e "\n${BLUE}Decode commands:${NC}"
    echo -e "${CYAN}Bash:${NC} printf \"%b\" \"\$(echo -e \"${url//%/\\x}\")\"" 
    echo -e "${CYAN}Python:${NC} import urllib.parse; urllib.parse.unquote('$url')"
    echo -e "${CYAN}JavaScript:${NC} decodeURIComponent('$url')"
    echo -e "${CYAN}PowerShell:${NC} [System.Web.HttpUtility]::UrlDecode('$url')"
}

# Bash script obfuscation
obfuscate_bash() {
    local input_file="$1"
    
    if [[ -z "$input_file" || ! -f "$input_file" ]]; then
        echo "Usage: obfuscate_bash <bash_script_file>"
        return 1
    fi
    
    # Check if it's a bash script
    local file_type=$(file "$input_file")
    if ! echo "$file_type" | grep -i "shell" > /dev/null && ! echo "$file_type" | grep -i "bash" > /dev/null; then
        echo -e "${YELLOW}Warning: File does not appear to be a shell script.${NC}"
        read -p "Continue anyway? [y/N] " continue_anyway
        [[ "$continue_anyway" != [yY]* ]] && return 1
    fi
    
    local base_name=$(basename "$input_file")
    local output_file="$OBFUSCATE_OUTPUT_DIR/${base_name%.sh}_obfuscated.sh"
    
    echo -e "${GREEN}Obfuscating Bash script:${NC} $input_file"
    echo -e "${BLUE}Output file:${NC} $output_file"
    
    # Create a temp file
    local temp_file="$OBFUSCATE_TEMP_DIR/temp_bash_$RANDOM.sh"
    cp "$input_file" "$temp_file"
    
    # Obfuscation techniques
    echo -e "${BLUE}Applying obfuscation techniques...${NC}"
    
    # 1. Variable name obfuscation - replace meaningful names
    echo -ne "  ${CYAN}Variable name obfuscation...${NC} "
    local var_count=0
    # Extract variable names first
    local variables=$(grep -oE '\$[a-zA-Z_][a-zA-Z0-9_]*' "$temp_file" | sort -u | sed 's/\$//' | grep -v '^[0-9]$')
    
    # Replace each variable with a random name
    for var in $variables; do
        # Skip special variables
        if [[ "$var" =~ ^(BASH_REMATCH|BASH_SOURCE|FUNCNAME|RANDOM|SECONDS|LINENO|MACHTYPE|PIPESTATUS|PWD|HOME|PATH|SHELL|HOSTNAME|USER|UID)$ ]]; then
            continue
        fi
        
        local new_var="_$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 8)"
        
        # Replace variable definitions and uses
        sed -i "s/\<$var=/\$(echo $new_var)=/g" "$temp_file"
        sed -i "s/\$\<$var\>/\$\$(echo $new_var)/g" "$temp_file"
        sed -i "s/\${$var}/\${\$(echo $new_var)}/g" "$temp_file"
        
        var_count=$((var_count+1))
    done
    echo -e "${GREEN}Done${NC} (obfuscated $var_count variables)"
    
    # 2. Add junk variables and functions
    echo -ne "  ${CYAN}Adding junk code...${NC} "
    local junk_count=$((RANDOM % 5 + 3))
    local junk=""
    
    for ((i=0; i<junk_count; i++)); do
        local junk_var="_$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 8)"
        local junk_value="$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c $((RANDOM % 20 + 5)))"
        junk+="$junk_var=\"$junk_value\"\n"
    done
    
    # Add junk functions
    for ((i=0; i<junk_count; i++)); do
        local junk_func="_$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 8)"
        junk+="function $junk_func() {\n  local _x=\"$RANDOM\"\n  local _y=\"$RANDOM\"\n  echo \"\$_x\$_y\" > /dev/null\n}\n"
    done
    
    # Insert junk after shebang or at beginning
    sed -i "1a\\
$junk" "$temp_file"
    echo -e "${GREEN}Done${NC} (added $junk_count junk items)"
    
    # 3. String obfuscation
    echo -ne "  ${CYAN}String obfuscation...${NC} "
    local string_count=0
    
    # Find strings in the script and obfuscate them
    strings=$(grep -oE '"[^"]+"|'"'"'[^'"'"']+'"'"'' "$temp_file" | grep -v '^"$' | grep -v "^'$")
    
    for string in $strings; do
        # Skip if it's a command substitution
        [[ "$string" =~ \$\(.*\) ]] && continue
        
        # Remove quotes
        string="${string#\'}"
        string="${string#\"}"
        string="${string%\'}"
        string="${string%\"}"
        
        # Skip empty strings and strings with variables
        [[ -z "$string" || "$string" =~ \$ ]] && continue
        
        # Choose a random encoding method
        local method=$((RANDOM % 3))
        local replace=""
        
        case $method in
            0) # Base64
                replace="\$(echo -n \"$(echo -n "$string" | base64)\" | base64 -d)"
                ;;
            1) # Hex
                replace="\$(echo -n \"$(echo -n "$string" | xxd -p | tr -d '\n')\" | xxd -p -r)"
                ;;
            2) # Char array
                replace="\\$("
                for ((i=0; i<${#string}; i++)); do
                    local char="${string:$i:1}"
                    replace+="echo -ne '\\\\$(printf "%03o" "'$char")';"
                done
                replace+=")"
                ;;
        esac
        
        # Replace in the file - careful with escaping
        if [[ -n "$replace" ]]; then
            local escaped_string=$(echo "$string" | sed 's/[\/&\.\*]/\\&/g')
            sed -i "s/\"$escaped_string\"/$replace/g" "$temp_file"
            sed -i "s/'$escaped_string'/$replace/g" "$temp_file"
            string_count=$((string_count+1))
        fi
    done
    echo -e "${GREEN}Done${NC} (obfuscated $string_count strings)"
    
    # 4. Add comment removal and code layout randomization
    echo -ne "  ${CYAN}Code layout randomization...${NC} "
    
    # Remove comments
    sed -i 's/^[[:space:]]*#.*$//' "$temp_file"
    
    # Random whitespace
    sed -i 's/^[[:space:]]*//g' "$temp_file" # Remove leading whitespace
    sed -i 's/[[:space:]]*$//g' "$temp_file" # Remove trailing whitespace
    
    # Random line breaks between statements
    sed -i 's/;/;\n/g' "$temp_file"
    
    echo -e "${GREEN}Done${NC}"
    
    # 5. Final wrapper with eval
    echo -ne "  ${CYAN}Applying final wrapper...${NC} "
    
    # Encode the entire script with Base64
    local encoded_script=$(cat "$temp_file" | base64 | tr -d '\n')
    
    # Create the final obfuscated script with wrapper
    cat > "$output_file" << EOF
#!/bin/bash
# Obfuscated with SENTINEL Obfuscation Module
# Original filename: $base_name
# Generated: $(date)

# Anti-debugging checks
if [[ \$BASH_COMMAND == *"debug"* || \$- == *"x"* ]]; then
  echo "Error: Cannot execute in debug mode"
  exit 1
fi

# Execute the obfuscated code
eval \$(echo '$encoded_script' | base64 -d)
EOF
    
    chmod +x "$output_file"
    echo -e "${GREEN}Done${NC}"
    
    # Clean up
    rm "$temp_file" 2>/dev/null
    
    echo -e "\n${GREEN}Bash script successfully obfuscated:${NC} $output_file"
}

# PowerShell script obfuscation
obfuscate_powershell() {
    local input_file="$1"
    
    if [[ -z "$input_file" || ! -f "$input_file" ]]; then
        echo "Usage: obfuscate_powershell <powershell_script_file>"
        return 1
    fi
    
    # Check if it's a powershell script
    if [[ "${input_file}" != *".ps1" ]]; then
        echo -e "${YELLOW}Warning: File does not have a .ps1 extension.${NC}"
        read -p "Continue anyway? [y/N] " continue_anyway
        [[ "$continue_anyway" != [yY]* ]] && return 1
    fi
    
    local base_name=$(basename "$input_file")
    local output_file="$OBFUSCATE_OUTPUT_DIR/${base_name%.ps1}_obfuscated.ps1"
    
    echo -e "${GREEN}Obfuscating PowerShell script:${NC} $input_file"
    echo -e "${BLUE}Output file:${NC} $output_file"
    
    # Create encoder command file
    local encoder_file="$OBFUSCATE_OUTPUT_DIR/ps_encoder_$(date +%Y%m%d%H%M%S).ps1"
    
    # Get the content of the input script
    local script_content=$(cat "$input_file")
    
    # Base64 encode the script (UTF-16LE for PowerShell)
    local encoded=$(iconv -f UTF-8 -t UTF-16LE "$input_file" 2>/dev/null | base64 -w0)
    if [[ $? -ne 0 ]]; then
        # Fallback if iconv fails
        local encoded=$(cat "$input_file" | base64 -w0)
    fi
    
    # Create the final obfuscated script
    cat > "$output_file" << EOF
# Obfuscated with SENTINEL Obfuscation Module
# Original filename: $base_name
# Generated: $(date)

# Anti-analysis techniques
if(\$Host.Name -eq 'ConsoleHost' -and \$env:prompt) {
    # Running in standard console
} else {
    # Exit if in an analysis environment
    Write-Output "Error: This script requires PowerShell Console"
    break
}

# Build the execution command
\$c = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('JGU9W1MneCcrdGVNK0B7fCsoJ3UnKyd0ZicrJ2knK0AiJH0rJ1MnXTo6JysnQVMnKydDSUknKydJJzsnZT1bU3'+
'lTVEBleHQnK0AiRU5DT0QiKydJTsuUycrJ107JHM9Igro8JGU6OlVURjgnLkdFdFN0UmluQChbY09OVmVydF06OkZyT21CYXNlNjRTdFJpbmcoJw=='))

# Command to decode and execute (triple-layer encoding)
\$b = '$encoded'

# Execute the obfuscated code
Invoke-Expression (\$c.Replace('@', 'y').Replace('suUy', '16LE'))
EOF
    
    # Create the encoder file (to show how the obfuscation works)
    cat > "$encoder_file" << EOF
# PowerShell Obfuscation Helper
# Generated: $(date)

# This script shows how the obfuscation in ${base_name%.ps1}_obfuscated.ps1 works

# The inner code that's built by the obfuscated script:
\$decoded_command = '[SysteM@{}+(u+tf+i+@"$}+S]::'+'AS'+'CII'+';e=[SySTExt'+'"ENCOD"'+'INsuUy'+'"];$s="<$e::UTF8.GEtStRinG([cONVert]::FrOMBase64StRing('

# What this does:
# 1. Builds various parts of the System.Text.Encoding namespace
# 2. Sets up UTF16LE encoding
# 3. Decodes a Base64 string

# The actual decoding process:
# Step 1: String manipulation replaces placeholders
# Step 2: The resulting string becomes a command to decode the Base64 payload
# Step 3: The decoded payload is executed with Invoke-Expression

# To manually decode for analysis:
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$encoded'))
EOF
    
    chmod +x "$output_file"
    
    echo -e "\n${GREEN}PowerShell script successfully obfuscated:${NC} $output_file"
    echo -e "${GREEN}Encoder explanation saved to:${NC} $encoder_file"
}

# Python script obfuscation
obfuscate_python() {
    local input_file="$1"
    
    if [[ -z "$input_file" || ! -f "$input_file" ]]; then
        echo "Usage: obfuscate_python <python_script_file>"
        return 1
    fi
    
    # Check if it's a python script
    if [[ "${input_file}" != *".py" ]]; then
        echo -e "${YELLOW}Warning: File does not have a .py extension.${NC}"
        read -p "Continue anyway? [y/N] " continue_anyway
        [[ "$continue_anyway" != [yY]* ]] && return 1
    fi
    
    # Check if python is installed
    if ! command -v python3 &>/dev/null; then
        echo -e "${RED}Error: python3 not found. Required for Python obfuscation.${NC}"
        return 1
    fi
    
    local base_name=$(basename "$input_file")
    local output_file="$OBFUSCATE_OUTPUT_DIR/${base_name%.py}_obfuscated.py"
    
    echo -e "${GREEN}Obfuscating Python script:${NC} $input_file"
    echo -e "${BLUE}Output file:${NC} $output_file"
    
    # Create a temporary Python obfuscation script
    local py_obfuscator="$OBFUSCATE_TEMP_DIR/py_obfuscator.py"
    
    cat > "$py_obfuscator" << 'EOF'
#!/usr/bin/env python3
import sys
import base64
import random
import string
import zlib
import re

def generate_random_string(length=8):
    return ''.join(random.choice(string.ascii_letters) for _ in range(length))

def obfuscate_python(script_content):
    # Remove comments and docstrings
    script_content = re.sub(r'"""[\s\S]*?"""|\'\'\'[\s\S]*?\'\'\'|#.*', '', script_content)
    
    # Obfuscate variable names
    var_names = re.findall(r'\b([a-zA-Z_][a-zA-Z0-9_]*)\s*=', script_content)
    var_names = set(var_names) - set(['self', 'cls', 'True', 'False', 'None', 'import', 'from', 'as', 'def', 'class', 'return', 'if', 'else', 'elif', 'for', 'while', 'try', 'except', 'finally'])
    
    var_mapping = {}
    for var in var_names:
        var_mapping[var] = '_' + generate_random_string()
    
    # Apply variable name replacements
    for old_name, new_name in var_mapping.items():
        # Use word boundaries to avoid partial matches
        script_content = re.sub(r'\b' + re.escape(old_name) + r'\b', new_name, script_content)
    
    # Compress and encode the script
    compressed = zlib.compress(script_content.encode('utf-8'))
    encoded = base64.b85encode(compressed).decode('utf-8')
    
    # Create the loader script
    loader = f"""#!/usr/bin/env python3
# Obfuscated with SENTINEL Obfuscation Module

import base64
import zlib
import sys

# Anti-debugging checks
try:
    import inspect
    if any(frame[3] == '<module>' for frame in inspect.stack()):
        pass  # Running normally
    else:
        sys.exit(1)  # Being debugged or imported
except:
    pass

# Decode and execute the obfuscated code
exec(zlib.decompress(base64.b85decode('{encoded}')).decode('utf-8'))
"""
    
    return loader

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python py_obfuscator.py <input_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    with open(input_file, 'r', encoding='utf-8') as f:
        script_content = f.read()
    
    obfuscated = obfuscate_python(script_content)
    print(obfuscated)
EOF
    
    # Make it executable
    chmod +x "$py_obfuscator"
    
    # Run the obfuscator
    python3 "$py_obfuscator" "$input_file" > "$output_file"
    
    # Make the output file executable
    chmod +x "$output_file"
    
    # Clean up
    rm "$py_obfuscator"
    
    echo -e "\n${GREEN}Python script successfully obfuscated:${NC} $output_file"
}

# JavaScript obfuscation
obfuscate_js() {
    local input_file="$1"
    
    if [[ -z "$input_file" || ! -f "$input_file" ]]; then
        echo "Usage: obfuscate_js <javascript_file>"
        return 1
    fi
    
    # Check if it's a JavaScript file
    if [[ "${input_file}" != *".js" ]]; then
        echo -e "${YELLOW}Warning: File does not have a .js extension.${NC}"
        read -p "Continue anyway? [y/N] " continue_anyway
        [[ "$continue_anyway" != [yY]* ]] && return 1
    fi
    
    local base_name=$(basename "$input_file")
    local output_file="$OBFUSCATE_OUTPUT_DIR/${base_name%.js}_obfuscated.js"
    
    echo -e "${GREEN}Obfuscating JavaScript:${NC} $input_file"
    echo -e "${BLUE}Output file:${NC} $output_file"
    
    # Create a temporary JavaScript obfuscation script
    local js_obfuscator="$OBFUSCATE_TEMP_DIR/js_obfuscator.js"
    
    cat > "$js_obfuscator" << 'EOF'
// Simple JavaScript obfuscator

const fs = require('fs');

// Check arguments
if (process.argv.length < 3) {
    console.error("Usage: node js_obfuscator.js <input_file>");
    process.exit(1);
}

// Read input file
const inputFile = process.argv[2];
let code = fs.readFileSync(inputFile, 'utf8');

// Function to generate random strings
function generateRandomString(length = 8) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let result = '_';
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

// Function to encode a string
function encodeString(str) {
    // Method 1: Convert to char codes
    if (Math.random() > 0.5) {
        return `String.fromCharCode(${[...str].map(c => c.charCodeAt(0)).join(',')})`;
    }
    // Method 2: Binary XOR encoding
    else {
        const key = Math.floor(Math.random() * 10) + 1;
        const encoded = [...str].map(c => (c.charCodeAt(0) ^ key).toString(16)).join('');
        return `(function(h,k){return[...h].map(c=>String.fromCharCode(parseInt(c,16)^k)).join('')})("${encoded}",${key})`;
    }
}

// Obfuscate strings
const stringLiterals = code.match(/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'/g) || [];
for (const str of stringLiterals) {
    const content = str.substring(1, str.length - 1);
    // Skip empty strings
    if (content.length === 0) continue;
    
    // Skip if string contains placeholders or looks like a regex
    if (content.includes('${') || content.includes('/')) continue;
    
    code = code.replace(str, encodeString(content));
}

// Obfuscate variable names
const variableNames = new Set();
const variableDeclRegex = /\b(let|var|const)\s+([a-zA-Z_$][a-zA-Z0-9_$]*)/g;
let match;
while ((match = variableDeclRegex.exec(code)) !== null) {
    variableNames.add(match[2]);
}

// Create mapping for variable replacement
const varMapping = {};
for (const name of variableNames) {
    // Skip reserved words and short names
    if (['window', 'document', 'console', 'eval', 'this'].includes(name) || name.length < 3) continue;
    varMapping[name] = generateRandomString();
}

// Replace variable names in the code
for (const [oldName, newName] of Object.entries(varMapping)) {
    const regex = new RegExp(`\\b${oldName}\\b`, 'g');
    code = code.replace(regex, newName);
}

// Final layer of obfuscation
const encodedCode = Buffer.from(code).toString('base64');
const finalCode = `
// Obfuscated with SENTINEL Obfuscation Module
// Original file: ${inputFile}
// Generated: ${new Date().toISOString()}

(function() {
    // Anti-debugging check
    const start = new Date();
    debugger;
    const end = new Date();
    if (end - start > 200) {
        // Likely being debugged
        window.location = 'about:blank';
        return;
    }
    
    // Execute the obfuscated code
    try {
        eval(atob('${encodedCode}'));
    } catch (e) {
        console.error('Error executing script');
    }
})();
`;

console.log(finalCode);
EOF
    
    # Check if node is available
    if command -v node &>/dev/null; then
        node "$js_obfuscator" "$input_file" > "$output_file" 2>/dev/null
    elif command -v nodejs &>/dev/null; then
        nodejs "$js_obfuscator" "$input_file" > "$output_file" 2>/dev/null
    else
        echo -e "${RED}Error: Node.js not found. Required for JavaScript obfuscation.${NC}"
        echo -e "${YELLOW}Falling back to basic obfuscation...${NC}"
        
        # Basic obfuscation without Node.js
        cat "$input_file" | base64 > "$output_file"
        
        # Create a basic wrapper
        cat > "$output_file" << EOF
// Obfuscated with SENTINEL Obfuscation Module
// Original file: $base_name
// Generated: $(date)

// Basic obfuscation (Node.js not available for advanced techniques)
(function() {
    try {
        eval(atob('$(cat "$input_file" | base64)'));
    } catch (e) {
        console.error('Error executing script');
    }
})();
EOF
    fi
    
    echo -e "\n${GREEN}JavaScript successfully obfuscated:${NC} $output_file"
    
    # Clean up
    rm "$js_obfuscator" 2>/dev/null
}

# PE (Windows executable) obfuscation
obfuscate_pe() {
    local input_file="$1"
    
    if [[ -z "$input_file" || ! -f "$input_file" ]]; then
        echo "Usage: obfuscate_pe <executable_file>"
        return 1
    fi
    
    # Check if it's a PE file
    local file_type=$(file "$input_file")
    if ! echo "$file_type" | grep -E "PE32|PE32\+" > /dev/null; then
        echo -e "${YELLOW}Warning: File does not appear to be a Windows PE executable.${NC}"
        read -p "Continue anyway? [y/N] " continue_anyway
        [[ "$continue_anyway" != [yY]* ]] && return 1
    fi
    
    local base_name=$(basename "$input_file")
    local output_file="$OBFUSCATE_OUTPUT_DIR/${base_name%.*}_obfuscated.${base_name##*.}"
    
    echo -e "${GREEN}Obfuscating Windows PE file:${NC} $input_file"
    echo -e "${BLUE}Output file:${NC} $output_file"
    
    # Basic techniques available without specialized tools
    
    # 1. UPX packing if available
    if command -v upx &>/dev/null; then
        echo -e "${BLUE}Applying UPX packing...${NC}"
        # Make a copy first
        cp "$input_file" "$output_file"
        upx -9 --ultra-brute --overlay=strip "$output_file" > /dev/null
    else
        echo -e "${YELLOW}UPX not found. Continuing with basic obfuscation...${NC}"
        cp "$input_file" "$output_file"
    fi
    
    # 2. Add junk data to the end of the file
    echo -e "${BLUE}Adding junk data...${NC}"
    dd if=/dev/urandom bs=1k count=$((RANDOM % 10 + 1)) >> "$output_file" 2>/dev/null
    
    echo -e "\n${GREEN}PE file obfuscation completed:${NC} $output_file"
    echo -e "${YELLOW}Note: For advanced PE obfuscation, consider specialized tools.${NC}"
    
    # Create a wrapper script to demonstrate how to execute
    local wrapper_file="$OBFUSCATE_OUTPUT_DIR/${base_name%.*}_launcher.ps1"
    
    cat > "$wrapper_file" << EOF
# PowerShell Launcher for Obfuscated PE
# Generated: $(date)

# Base64 encoded file (truncated for brevity)
# In a real scenario, you would include the full Base64 encoded executable
\$encodedExecutable = "$(head -c 100 "$output_file" | base64)"
# ... (truncated)

# Demonstrate how to execute from memory
# Note: This is just for demonstration, actual code would include the full file
Write-Host "This script demonstrates memory execution techniques for PE files."
Write-Host "For security reasons, it doesn't include actual execution code."
Write-Host "The obfuscated PE is saved at: $output_file"
EOF
    
    echo -e "${BLUE}Created launcher script:${NC} $wrapper_file"
}

# ELF (Linux executable) obfuscation
obfuscate_elf() {
    local input_file="$1"
    
    if [[ -z "$input_file" || ! -f "$input_file" ]]; then
        echo "Usage: obfuscate_elf <executable_file>"
        return 1
    fi
    
    # Check if it's an ELF file
    local file_type=$(file "$input_file")
    if ! echo "$file_type" | grep "ELF" > /dev/null; then
        echo -e "${YELLOW}Warning: File does not appear to be an ELF executable.${NC}"
        read -p "Continue anyway? [y/N] " continue_anyway
        [[ "$continue_anyway" != [yY]* ]] && return 1
    fi
    
    local base_name=$(basename "$input_file")
    local output_file="$OBFUSCATE_OUTPUT_DIR/${base_name%.*}_obfuscated"
    
    echo -e "${GREEN}Obfuscating ELF file:${NC} $input_file"
    echo -e "${BLUE}Output file:${NC} $output_file"
    
    # Basic techniques available without specialized tools
    
    # 1. UPX packing if available
    local packed_file="$OBFUSCATE_TEMP_DIR/${base_name}_packed"
    if command -v upx &>/dev/null; then
        echo -e "${BLUE}Applying UPX packing...${NC}"
        cp "$input_file" "$packed_file"
        upx -9 --ultra-brute --overlay=strip "$packed_file" > /dev/null
        
        # If packing successful, use packed file as base
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}UPX packing successful.${NC}"
        else
            echo -e "${YELLOW}UPX packing failed, using original file.${NC}"
            cp "$input_file" "$packed_file"
        fi
    else
        echo -e "${YELLOW}UPX not found. Continuing with basic obfuscation...${NC}"
        cp "$input_file" "$packed_file"
    fi
    
    # 2. Create a self-extracting wrapper script
    echo -e "${BLUE}Creating self-extracting wrapper...${NC}"
    
    # Base64 encode the executable
    local encoded_bin=$(base64 -w 0 "$packed_file")
    
    # Create the wrapper script
    cat > "$output_file" << EOF
#!/bin/bash
# Self-extracting ELF executable
# Obfuscated with SENTINEL Obfuscation Module
# Original: $base_name
# Generated: $(date)

# Anti-debugging check
if [[ \$BASH_COMMAND == *"debug"* || \$- == *"x"* ]]; then
  echo "Error: Cannot execute in debug mode"
  exit 1
fi

# Check if running in container/VM
if [[ -f /.dockerenv || -f /proc/vz/veinfo ]]; then
  echo "Error: Environment not supported"
  exit 1
fi

# Extract and execute
EXEC_DATA="$encoded_bin"
TMP_FILE=\$(mktemp)
echo "\$EXEC_DATA" | base64 -d > "\$TMP_FILE"
chmod +x "\$TMP_FILE"
"\$TMP_FILE" "\$@"
EXIT_CODE=\$?
rm -f "\$TMP_FILE"
exit \$EXIT_CODE
EOF
    
    chmod +x "$output_file"
    
    # Clean up
    rm "$packed_file" 2>/dev/null
    
    echo -e "\n${GREEN}ELF file successfully obfuscated:${NC} $output_file"
    echo -e "${YELLOW}Note: For advanced ELF obfuscation, consider specialized tools.${NC}"
}

# Split a file into multiple chunks
obfuscate_split() {
    local input_file="$1"
    local chunk_size="${2:-1024}"  # Default 1KB chunks
    
    if [[ -z "$input_file" || ! -f "$input_file" ]]; then
        echo "Usage: obfuscate_split <file> [chunk_size_in_KB]"
        return 1
    fi
    
    local base_name=$(basename "$input_file")
    local output_dir="$OBFUSCATE_OUTPUT_DIR/split_${base_name}_$(date +%Y%m%d%H%M%S)"
    
    # Create output directory
    mkdir -p "$output_dir"
    
    echo -e "${GREEN}Splitting file:${NC} $input_file"
    echo -e "${BLUE}Chunk size:${NC} ${chunk_size}KB"
    echo -e "${BLUE}Output directory:${NC} $output_dir"
    
    # Calculate file size and number of chunks
    local file_size=$(stat -c %s "$input_file")
    local chunk_bytes=$((chunk_size * 1024))
    local num_chunks=$(( (file_size + chunk_bytes - 1) / chunk_bytes ))
    
    echo -e "${BLUE}File size:${NC} $file_size bytes"
    echo -e "${BLUE}Number of chunks:${NC} $num_chunks"
    
    # Split the file
    local temp_split="$OBFUSCATE_TEMP_DIR/split_temp_"
    split -b ${chunk_size}k "$input_file" "$temp_split"
    
    # Process each chunk
    local count=0
    local manifest="$output_dir/manifest.txt"
    echo "# Split file manifest" > "$manifest"
    echo "# Original file: $base_name" >> "$manifest"
    echo "# Generated: $(date)" >> "$manifest"
    echo "# Total chunks: $num_chunks" >> "$manifest"
    echo "# Instructions: Use the reassemble.sh script to reconstruct the original file" >> "$manifest"
    echo "" >> "$manifest"
    
    for chunk in "$temp_split"*; do
        count=$((count+1))
        
        # Generate a random name for the chunk
        local chunk_name="chunk_$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 12).bin"
        
        # Obfuscate the chunk (simple XOR with random key)
        local key=$((RANDOM % 255 + 1))
        
        # XOR the chunk with the key
        cat "$chunk" | python3 -c "import sys; key=$key; sys.stdout.buffer.write(bytes([b ^ key for b in sys.stdin.buffer.read()]))" > "$output_dir/$chunk_name"
        
        # Store chunk information in manifest
        echo "$count:$chunk_name:$key" >> "$manifest"
        
        rm "$chunk"
    done
    
    # Create reassembly script
    local reassembly_script="$output_dir/reassemble.sh"
    
    cat > "$reassembly_script" << EOF
#!/bin/bash
# File reassembly script
# Generated: $(date)

OUTPUT_FILE="\${1:-reconstructed_$base_name}"

if [ -f "\$OUTPUT_FILE" ]; then
    echo "Output file already exists. Overwrite? (y/n)"
    read confirm
    if [ "\$confirm" != "y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

echo "Reassembling file into: \$OUTPUT_FILE"
> "\$OUTPUT_FILE"

count=0
total_chunks=$num_chunks

# Process each chunk according to manifest
while IFS=':' read -r chunk_num chunk_name key || [[ -n "\$chunk_num" ]]; do
    # Skip comment lines and empty lines
    [[ "\$chunk_num" =~ ^#.*$ || -z "\$chunk_num" ]] && continue
    
    count=\$((count+1))
    echo -ne "Processing chunk \$count/\$total_chunks (\$chunk_name)... "
    
    # Decrypt chunk (reverse the XOR operation)
    cat "\$chunk_name" | python3 -c "import sys; key=\$key; sys.stdout.buffer.write(bytes([b ^ key for b in sys.stdin.buffer.read()]))" >> "\$OUTPUT_FILE"
    
    echo "done."
done < manifest.txt

echo "File reassembled successfully."
echo "Original file size: $file_size bytes"
echo "Reassembled file size: \$(stat -c %s "\$OUTPUT_FILE") bytes"

# Verify the file with a checksum if available
if command -v sha256sum > /dev/null; then
    echo "SHA256 checksum: \$(sha256sum "\$OUTPUT_FILE" | cut -d' ' -f1)"
fi
EOF
    
    chmod +x "$reassembly_script"
    
    echo -e "\n${GREEN}File successfully split and obfuscated:${NC}"
    echo -e "  ${BLUE}Output directory:${NC} $output_dir"
    echo -e "  ${BLUE}Manifest:${NC} $manifest"
    echo -e "  ${BLUE}Reassembly script:${NC} $reassembly_script"
    echo -e "\n${YELLOW}To reassemble the file:${NC}"
    echo -e "  cd $output_dir"
    echo -e "  ./reassemble.sh [output_filename]"
}

# Hide a file inside another file
obfuscate_hide() {
    local hidden_file="$1"
    local carrier_file="$2"
    
    if [[ -z "$hidden_file" || ! -f "$hidden_file" ]]; then
        echo "Usage: obfuscate_hide <file_to_hide> <carrier_file>"
        return 1
    fi
    
    if [[ -z "$carrier_file" || ! -f "$carrier_file" ]]; then
        echo "Error: Carrier file not found"
        echo "Usage: obfuscate_hide <file_to_hide> <carrier_file>"
        return 1
    fi
    
    local hidden_name=$(basename "$hidden_file")
    local carrier_name=$(basename "$carrier_file")
    local output_file="$OBFUSCATE_OUTPUT_DIR/carrier_$(date +%Y%m%d%H%M%S).${carrier_file##*.}"
    local extractor_script="$OBFUSCATE_OUTPUT_DIR/extract_${hidden_name}_$(date +%Y%m%d%H%M%S).sh"
    
    echo -e "${GREEN}Hiding file:${NC} $hidden_file"
    echo -e "${BLUE}Inside carrier:${NC} $carrier_file"
    echo -e "${BLUE}Output file:${NC} $output_file"
    
    # Add a unique marker that's unlikely to appear in the carrier file
    local marker="SENTINEL_HIDDEN_DATA_$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16)"
    
    # Base64 encode the hidden file
    local encoded_data=$(base64 -w 0 "$hidden_file")
    
    # Create the carrier with hidden data
    cat "$carrier_file" > "$output_file"
    echo "" >> "$output_file"
    echo "# $marker" >> "$output_file"
    echo "$encoded_data" >> "$output_file"
    echo "# END_$marker" >> "$output_file"
    
    # Create extraction script
    cat > "$extractor_script" << EOF
#!/bin/bash
# File extraction script
# Extract hidden file ($hidden_name) from carrier
# Generated: $(date)

CARRIER="\${1:-$output_file}"
OUTPUT="\${2:-extracted_$hidden_name}"

if [ ! -f "\$CARRIER" ]; then
    echo "Error: Carrier file not found: \$CARRIER"
    exit 1
fi

if [ -f "\$OUTPUT" ]; then
    echo "Output file already exists. Overwrite? (y/n)"
    read confirm
    if [ "\$confirm" != "y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

echo "Extracting hidden file from carrier..."

# Extract data between the markers
DATA=\$(sed -n "/$marker/,/END_$marker/p" "\$CARRIER" | grep -v "$marker")

if [ -z "\$DATA" ]; then
    echo "Error: Hidden data not found in carrier file."
    exit 1
fi

# Decode the data
echo "\$DATA" | base64 -d > "\$OUTPUT"

echo "File extracted successfully to: \$OUTPUT"
echo "File size: \$(stat -c %s "\$OUTPUT") bytes"

# Verify the file type
if command -v file > /dev/null; then
    echo "File type: \$(file -b "\$OUTPUT")"
fi
EOF
    
    chmod +x "$extractor_script"
    
    echo -e "\n${GREEN}File successfully hidden:${NC}"
    echo -e "  ${BLUE}Carrier with hidden data:${NC} $output_file"
    echo -e "  ${BLUE}Extraction script:${NC} $extractor_script"
    echo -e "\n${YELLOW}To extract the hidden file:${NC}"
    echo -e "  $extractor_script [carrier_file] [output_file]"
}

# Custom compression with obfuscated headers
obfuscate_compress() {
    local input_file="$1"
    local strength="${2:-9}"  # Compression strength 1-9
    
    if [[ -z "$input_file" || ! -f "$input_file" ]]; then
        echo "Usage: obfuscate_compress <file> [compression_strength]"
        return 1
    fi
    
    # Validate compression strength
    if ! [[ "$strength" =~ ^[1-9]$ ]]; then
        echo "Error: Compression strength must be between 1-9"
        return 1
    fi
    
    local base_name=$(basename "$input_file")
    local output_file="$OBFUSCATE_OUTPUT_DIR/${base_name%.*}_compressed.bin"
    local decompressor="$OBFUSCATE_OUTPUT_DIR/decompress_${base_name%.*}_$(date +%Y%m%d%H%M%S).sh"
    
    echo -e "${GREEN}Compressing and obfuscating file:${NC} $input_file"
    echo -e "${BLUE}Compression level:${NC} $strength"
    echo -e "${BLUE}Output file:${NC} $output_file"
    
    # Generate a random key for XOR obfuscation
    local key=$((RANDOM % 255 + 1))
    
    # Generate a random magic number for the header
    local magic=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 8)
    
    # Create a temp file for compressed data
    local temp_compressed="$OBFUSCATE_TEMP_DIR/comp_temp_$RANDOM"
    
    # Compress the file using gzip
    cat "$input_file" | gzip -$strength > "$temp_compressed"
    
    # Create the final file with our custom format
    # Format: MAGIC(8) + VERSION(2) + KEYLEN(1) + KEY(N) + ORIGNAME_LEN(2) + ORIGNAME(N) + DATA
    local orig_name_len=${#base_name}
    local version="01"  # Two-digit version number
    
    # Write header and compressed data
    {
        echo -n "$magic"
        echo -n "$version"
        echo -n $(printf "\\$(printf '%03o' ${#key})")
        echo -n $(printf "\\$(printf '%03o' $key)")
        echo -n $(printf "\\$(printf '%03o' ${orig_name_len})")
        echo -n "$base_name"
        
        # XOR the compressed data with the key
        cat "$temp_compressed" | python3 -c "import sys; key=$key; sys.stdout.buffer.write(bytes([b ^ key for b in sys.stdin.buffer.read()]))"
    } > "$output_file"
    
    # Clean up temp file
    rm "$temp_compressed" 2>/dev/null
    
    # Create decompression script
    cat > "$decompressor" << EOF
#!/bin/bash
# Custom format decompressor
# For file: $base_name
# Generated: $(date)

COMPRESSED="\${1:-$output_file}"
OUTPUT="\${2:-decompressed_$base_name}"

if [ ! -f "\$COMPRESSED" ]; then
    echo "Error: Compressed file not found: \$COMPRESSED"
    exit 1
fi

if [ -f "\$OUTPUT" ]; then
    echo "Output file already exists. Overwrite? (y/n)"
    read confirm
    if [ "\$confirm" != "y" ]; then
        echo "Aborted."
        exit 1
    fi
fi

echo "Decompressing file..."

# Extract and verify magic number
MAGIC=\$(dd if="\$COMPRESSED" bs=8 count=1 2>/dev/null)
if [ "\$MAGIC" != "$magic" ]; then
    echo "Error: Invalid file format or corrupted header"
    exit 1
fi

# Extract version
VERSION=\$(dd if="\$COMPRESSED" bs=1 skip=8 count=2 2>/dev/null)
if [ "\$VERSION" != "$version" ]; then
    echo "Error: Unsupported version: \$VERSION"
    exit 1
fi

# Extract key length (1 byte)
KEY_LEN=\$(dd if="\$COMPRESSED" bs=1 skip=10 count=1 2>/dev/null | od -An -td1 | tr -d ' ')

# Extract key
KEY=\$(dd if="\$COMPRESSED" bs=1 skip=11 count=\$KEY_LEN 2>/dev/null | od -An -td1 | tr -d ' ')

# Extract original name length
ORIG_NAME_LEN=\$(dd if="\$COMPRESSED" bs=1 skip=\$((11 + KEY_LEN)) count=1 2>/dev/null | od -An -td1 | tr -d ' ')

# Extract original name
ORIG_NAME=\$(dd if="\$COMPRESSED" bs=1 skip=\$((12 + KEY_LEN)) count=\$ORIG_NAME_LEN 2>/dev/null)

# Calculate offset to compressed data
DATA_OFFSET=\$((12 + KEY_LEN + ORIG_NAME_LEN))

echo "File info:"
echo "  Original name: \$ORIG_NAME"
echo "  Format version: \$VERSION"
echo "  Decompressing with key: \$KEY"

# Extract, deobfuscate and decompress the data
dd if="\$COMPRESSED" bs=1 skip=\$DATA_OFFSET 2>/dev/null | \\
  python3 -c "import sys; key=\$KEY; sys.stdout.buffer.write(bytes([b ^ key for b in sys.stdin.buffer.read()]))" | \\
  gunzip > "\$OUTPUT"

echo "File decompressed successfully to: \$OUTPUT"
echo "File size: \$(stat -c %s "\$OUTPUT") bytes"

# Verify the file type
if command -v file > /dev/null; then
    echo "File type: \$(file -b "\$OUTPUT")"
fi
EOF
    
    chmod +x "$decompressor"
    
    echo -e "\n${GREEN}File successfully compressed and obfuscated:${NC}"
    echo -e "  ${BLUE}Compressed size:${NC} $(stat -c %s "$output_file") bytes"
    echo -e "  ${BLUE}Original size:${NC} $(stat -c %s "$input_file") bytes"
    echo -e "  ${BLUE}Ratio:${NC} $((100 * $(stat -c %s "$output_file") / $(stat -c %s "$input_file")))%"
    echo -e "  ${BLUE}Decompressor:${NC} $decompressor"
    echo -e "\n${YELLOW}To decompress:${NC}"
    echo -e "  $decompressor [input_file] [output_file]"
}

# Check for required tools on load
obfuscate_check_tools > /dev/null

# Display module loaded message
echo -e "${GREEN}[+]${NC} File obfuscation module loaded with ${CYAN}$(( $(declare -F | grep -c "^declare -f obfuscate_") ))${NC} obfuscation techniques."