#!/usr/bin/env bash
# SENTINEL Context Module
# Provides integration between command learning and chat systems

# Check if Python is available
if ! command -v python3 &>/dev/null; then
    echo "Warning: Python 3 not found. SENTINEL context features disabled."
    return 1
fi

# Path to context script
SENTINEL_CTX_DIR="$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")/contrib"
SENTINEL_CTX_SCRIPT="$SENTINEL_CTX_DIR/sentinel_context.py"

# Make sure the context script exists
if [ ! -f "$SENTINEL_CTX_SCRIPT" ]; then
    echo "Error: sentinel_context.py not found at $SENTINEL_CTX_SCRIPT"
    return 1
fi

# Record successful commands to context
function __sentinel_record_command() {
    local exit_code=$1
    local command="$2"
    
    # Only record successful, non-empty commands
    if [ $exit_code -eq 0 ] && [ -n "$command" ]; then
        # Don't record commands with sensitive keywords
        if ! echo "$command" | grep -q -i "password\|secret\|key\|token\|credential"; then
            # Run context update in background to avoid slowing down the shell
            python3 "$SENTINEL_CTX_SCRIPT" --record "$command" --exit-code $exit_code >/dev/null 2>&1 &
        fi
    fi
}

# Hook into command completion
function __sentinel_command_done() {
    local exit_code=$?
    local last_cmd=$(HISTTIMEFORMAT= history 1 | sed 's/^[ 0-9]\+[ ]\+//')
    
    __sentinel_record_command $exit_code "$last_cmd"
    return $exit_code
}

# Add our function to PROMPT_COMMAND to run after each command
# Use trap DEBUG to capture the command before execution
if [[ "$PROMPT_COMMAND" != *"__sentinel_command_done"* ]]; then
    PROMPT_COMMAND="__sentinel_command_done;${PROMPT_COMMAND:-:}"
fi

# Analyze and record sequences of commands
function __sentinel_analyze_sequence() {
    local count=${1:-5}
    # Get last N commands from history
    local cmds=$(HISTTIMEFORMAT= history $count | sed 's/^[ 0-9]\+[ ]\+//')
    
    # Convert to comma-separated list for the context script
    local cmd_list=$(echo "$cmds" | tr '\n' ',' | sed 's/,$//')
    
    # Add sequence to context
    python3 "$SENTINEL_CTX_SCRIPT" --add-sequence "$cmd_list" >/dev/null 2>&1 &
}

# Function to update context manually
function sentinel_update_context() {
    python3 "$SENTINEL_CTX_SCRIPT" --update
    echo "SENTINEL context updated"
}

# Function to show current context
function sentinel_show_context() {
    python3 "$SENTINEL_CTX_SCRIPT" --get | jq . 2>/dev/null || 
        python3 "$SENTINEL_CTX_SCRIPT" --get
}

# Function to get context formatted for humans
function sentinel_context() {
    python3 "$SENTINEL_CTX_SCRIPT" --for-llm
}

# Function to suggest commands based on context
function sentinel_smart_suggest() {
    local prefix="$1"
    if [ -z "$prefix" ]; then
        echo "Usage: sentinel_smart_suggest <command_prefix>"
        return 1
    fi
    
    # Get suggestions based on prefix
    python3 "$SENTINEL_CTX_SCRIPT" --suggest "$prefix" | 
        jq -r '.[] | "\(.confidence*100 | floor)% \(.command) - \(.description)"' 2>/dev/null ||
        python3 "$SENTINEL_CTX_SCRIPT" --suggest "$prefix"
}

# Integrate with other SENTINEL modules if they exist
if declare -F module_enable >/dev/null; then
    # Check if sentinel_ml is loaded
    if [[ "${SENTINEL_LOADED_MODULES[sentinel_ml]}" == "1" ]]; then
        echo "Integrating context with sentinel_ml module..."
        
        # Periodically analyze command sequences when using sentinel_ml
        # This will run sequence analysis every 20 commands
        if [ -n "$SENTINEL_ML_ENABLED" ] && [ "$SENTINEL_ML_ENABLED" -eq 1 ]; then
            function __sentinel_periodic_sequence_analysis() {
                # Run sequence analysis every ~20 commands (based on hash)
                local cmd="$1"
                local hash=$(($(echo "$cmd" | cksum | cut -d' ' -f1) % 20))
                if [ "$hash" -eq 0 ]; then
                    __sentinel_analyze_sequence 5
                fi
            }
            
            # Hook into the existing PROMPT_COMMAND
            if [[ "$PROMPT_COMMAND" != *"__sentinel_periodic_sequence_analysis"* ]]; then
                PROMPT_COMMAND="__sentinel_periodic_sequence_analysis \$(HISTTIMEFORMAT= history 1 | sed 's/^[ 0-9]\\+[ ]\\+//');${PROMPT_COMMAND:-:}"
            fi
        fi
    fi
    
    # Check if sentinel_chat is loaded
    if [[ "${SENTINEL_LOADED_MODULES[sentinel_chat]}" == "1" ]]; then
        echo "Integrating context with sentinel_chat module..."
        
        # Export context for chat
        export SENTINEL_CONTEXT_AVAILABLE=1
    fi
fi

# Create bash completion for sentinel context commands
complete -F "__sentinel_completion" sentinel_smart_suggest

function __sentinel_completion() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${#cur} -ge 1 ]; then
        local suggestions=$(python3 "$SENTINEL_CTX_SCRIPT" --suggest "$cur" | 
                          jq -r '.[].command' 2>/dev/null)
        
        if [ -n "$suggestions" ]; then
            COMPREPLY=( $(compgen -W "$suggestions" -- "$cur") )
        fi
    fi
}

# Command aliases
alias ctx="sentinel_context"
alias ctxshow="sentinel_show_context"
alias ctxupdate="sentinel_update_context"
alias suggest="sentinel_smart_suggest"

# Initial context update on module load
sentinel_update_context >/dev/null 2>&1 &

echo "SENTINEL Context module loaded" 