#!/usr/bin/env bash
# SENTINEL Installer - Terminal Functions

prompt_terminal_selection() {
    if [[ $INTERACTIVE -eq 0 ]]; then
        log "Non-interactive mode: Skipping terminal selection."
        return
    fi

    step "Select your preferred terminal"
    echo "1. Kitty"
    echo "2. XFCE4 Terminal"
    echo "3. Default"
    read -r -p "Enter the number of your preferred terminal: " terminal_selection

    case "$terminal_selection" in
        1)
            TERMINAL_PREFERRED="kitty"
            ;;
        2)
            TERMINAL_PREFERRED="xfce4-terminal"
            ;;
        *)
            TERMINAL_PREFERRED="default"
            ;;
    esac

    # Update the config.yaml file
    yq -i -y ".terminal.preferred = \"$TERMINAL_PREFERRED\"" "$SENTINEL_CONFIG_FILE"
    ok "Terminal selection saved."
}
