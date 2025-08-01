# SENTINEL Installer

This directory contains the scripts for the SENTINEL installer. The installer is a modular system, with each component responsible for a specific part of the installation process.

## How it works

The main entry point for the installer is the `install.sh` script in the root of the repository. This script is a simple wrapper that calls the main installer logic in `installer/main.sh`.

The `installer/main.sh` script sources the other installer scripts in this directory and calls the functions in the correct order.

## Configuration

The installer is configured using a YAML file. By default, it will look for a `config.yaml` file in the root of the repository. If it doesn't find one, it will use the `config.yaml.dist` file as a fallback.

To customize your installation, you can copy `config.yaml.dist` to `config.yaml` and modify it to your needs.

The configuration file is parsed by the `installer/config.py` script, which exports the configuration values as environment variables.

## Scripts

-   **`main.sh`**: The main entry point for the installer.
-   **`helpers.sh`**: Helper functions for logging, file operations, etc.
-   **`dependencies.sh`**: Functions for checking dependencies.
-   **`directories.sh`**: Functions for setting up the directory structure.
-   **`python.sh`**: Functions for setting up the Python virtual environment.
-   **`blesh.sh`**: Functions for installing and configuring BLE.sh.
-   **`bash.sh`**: Functions for patching the user's bashrc and copying shell files.
-   **`config.py`**: A Python script that parses the configuration file and exports the values as environment variables.
