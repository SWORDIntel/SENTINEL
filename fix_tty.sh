#!/usr/bin/env bash
# SENTINEL Emergency TTY State Fix
stty sane
stty cooked
stty echo
clear
echo "TTY state has been reset."
echo "Your terminal should be working normally again."
