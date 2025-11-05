#!/usr/bin/env bash
# SENTINEL Installer - Shell Functions

prompt_shell_selection() {
    if [[ $INTERACTIVE -eq 0 ]]; then
        log "Non-interactive mode: Skipping shell selection."
        return
    fi

    step "Select your preferred shell"
    echo "1. Bash"
    echo "2. Zsh"
    read -r -p "Enter the number of your preferred shell: " shell_selection

    case "$shell_selection" in
        2)
            SHELL_PREFERRED="zsh"
            ;;
        *)
            SHELL_PREFERRED="bash"
            ;;
    esac

    # Update the config.yaml file
    yq -i -y ".shell.preferred = \"$SHELL_PREFERRED\"" "$SENTINEL_CONFIG_FILE"
    ok "Shell selection saved."
}
