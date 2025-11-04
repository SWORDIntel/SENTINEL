# SENTINEL: Secure ENhanced Terminal INtelligent Layer

![SENTINEL Logo](https://via.placeholder.com/800x200/0d1117/30a14e?text=SENTINEL)

A hardened, optimized, security-focused shell environment for advanced users, researchers, and security professionals, featuring intelligent context-aware assistance, comprehensive autocomplete, environment management, and cybersecurity capabilities.

## Table of Contents

- [Core Features](#core-features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Features](#features)
  - [Path Management](#path-management)
  - [Python Integration](#python-integration)
  - [Virtual Environments](#virtual-environments)
  - [AI/ML Stack](#aiml-stack)
  - [ZFS Snapshots](#zfs-snapshots)
  - [Module System](#module-system)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Disclaimer](#disclaimer)

## Core Features

- **Comprehensive Security**: HMAC verification for module integrity, permission hardening, and execution sandboxing.
- **Intelligent Command Prediction**: Context-aware suggestions based on history analysis, project context, and statistical modeling.
- **Enhanced Autocomplete**: A hybrid system providing robust autocompletion for commands, arguments, and file paths.
- **Virtual Environment Management**: Automatic Python virtual environment detection, switching, and dependency tracking.
- **Performance Optimization**: Lazy loading, dependency-based module system, and caching to maintain a responsive terminal.

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/sentinel.git
cd sentinel

# Run the installer
bash install.sh

# Restart your shell or source the configuration
source ~/.bashrc
```

The installer will guide you through the installation process. It will check for dependencies, create the necessary directory structure, and patch your `~/.bashrc` file.

## Configuration

SENTINEL is configured through a combination of environment variables and a YAML file.

### Environment Variables

The following environment variables can be set in your `~/.bashrc.postcustom` or other shell configuration files to customize your SENTINEL experience:

-   `SENTINEL_ROOT`: The root directory of your SENTINEL installation. This is set by the installer.
-   `SENTINEL_DATASCIENCE_DIR`: The directory for your data science projects. Defaults to `$HOME/datascience`.
-   `PYTHON_INSTALL_DIR`: Specifies the base directory for Python installations (e.g., `/opt/python`).
-   `CODE_DIR`: Defines the default directory for code projects (e.g., `/opt/code`).
-   `HOMEBREW_PATH`: Path to the Homebrew executable if installed in a non-standard location.
-   `OPENVINO_SETUPVARS`: Path to the OpenVINO `setupvars.sh` script.
-   `C_TOOLCHAIN_PATH`: Base directory for custom C/C++ toolchains.
-   `WAVETERM_PATH`: Path to the Waveterm executable.
-   `ZFS_BUILD_DIR`, `ZFS_AI_DIR`, `ZFS_CODE_DIR`, etc.: Base directories for ZFS-enforced paths, allowing customization of where specific command types are expected to run.

### Configuration File

SENTINEL is configured using a YAML file. By default, it will look for a `config.yaml` file in the root of the repository. If it doesn't find one, it will use the `config.yaml.dist` file as a fallback.

To customize your installation, you can copy `config.yaml.dist` to `config.yaml` and modify it to your needs.

The configuration file allows you to:
-   Enable or disable modules.
-   Configure Python environment settings.
-   Set security verification options.
-   Configure logging levels and locations.

For more information on the available configuration options, please see the `config.yaml.dist` file.

## Features

SENTINEL provides a rich set of functions and features to enhance your shell experience.

### Path Management

The `path_manager.sh` script provides a set of functions for managing your shell's `PATH` persistently.

-   `add_path [path]`: Adds a directory to your `PATH` for the current session and saves it to a configuration file to be loaded in future sessions. If no path is provided, it will use the current directory.
-   `remove_path [path]`: Removes a directory from your persistent `PATH` configuration.
-   `list_paths`: Lists all the directories in your persistent `PATH` configuration.
-   `refresh_paths`: Reloads your `PATH` from the persistent configuration file.

### Python Integration

The `python_integration.module` provides a bridge between Bash and Python, with functions for managing state, configuration, and inter-process communication.

-   `sentinel_config_get <key>`: Gets a configuration value.
-   `sentinel_config_set <key> <value>`: Sets a configuration value.
-   `sentinel_state_get <key>`: Gets a state value.
-   `sentinel_state_set <key> <value>`: Sets a state value.
-   `sentinel_python_exec <script> [args...]`: Executes a Python script.
-   `sentinel_python_module_install <module>`: Installs a Python module.
-   `sentinel_python_module_list`: Lists installed Python modules.

### Virtual Environments

The `venv_helpers` script provides a `mkvenv` function for creating Python virtual environments.

-   `mkvenv [directory_name]`: Creates a Python virtual environment in the specified directory (or `.venv` by default) and installs a predefined set of packages.

### AI/ML Stack

SENTINEL includes a set of aliases and functions for working with AI and machine learning tools.

-   `ai-env`: Activates the data science environment.
-   `npu-test`: Runs a test of the NPU.
-   `ai-bench`: Runs a benchmark of the AI stack.
-   `aitest`: Runs a comprehensive test of the AI stack.
-   `aibench`: Runs a benchmark of the AI stack.
-   `datascience`: Activates the data science environment and sets up the necessary environment variables.

### ZFS Snapshots

SENTINEL provides a `zfssnapshot` function for creating ZFS snapshots.

-   `zfssnapshot <snapshot_name_prefix>`: Creates a ZFS snapshot with the given prefix.

### Module System

SENTINEL's functionality is organized into a modular system that allows you to enable or disable features as you see fit. The `module_manager.module` provides a set of functions for managing modules.

-   `module_enable <module_name>`: Enables a module.
-   `module_disable <module_name>`: Disables a module.
-   `module_list`: Lists all available modules and their status.
-   `module_sign <module_name>`: Signs a module with an HMAC signature for integrity verification.

## Usage Examples

### Create a new Python virtual environment

```bash
mkvenv my_project_env
```

### Add a directory to your PATH

```bash
add_path ~/bin
```

### Run a benchmark of the AI stack

```bash
aibench
```

### Create a ZFS snapshot

```bash
zfssnapshot my_project_
```

## Troubleshooting

-   Check the logs in `~/logs/` for any errors.
-   Run the installer again with the `--non-interactive` flag to see the full output.
-   If you are having issues with a specific module, you can disable it in your `config.yaml` file.

## Contributing

Contributions are welcome! Please see the `CONTRIBUTING.md` file for more information on how to contribute to the project.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This shell environment is highly customized for a specific system and workflow. While it can serve as a template or inspiration, you will likely need to modify the configuration files, scripts, and paths to suit your own needs.
