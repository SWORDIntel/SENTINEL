# Load BLE.sh if available, otherwise use standard completion
if [ -f ~/.sentinel/blesh_loader.sh ]; then
    source ~/.sentinel/blesh_loader.sh
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi 