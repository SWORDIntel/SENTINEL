# SENTINEL: Secure ENhanced Terminal INtelligent Layer

![SENTINEL Logo](https://via.placeholder.com/800x200/0d1117/30a14e?text=SENTINEL)

A hardened, optimized, security-focused shell environment for advanced users, researchers, and security professionals, featuring intelligent context-aware assistance, comprehensive autocomplete, environment management, and cybersecurity capabilities.

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

SENTINEL is configured using a YAML file. By default, it will look for a `config.yaml` file in the root of the repository. If it doesn't find one, it will use the `config.yaml.dist` file as a fallback.

To customize your installation, you can copy `config.yaml.dist` to `config.yaml` and modify it to your needs.

The configuration file allows you to:
-   Enable or disable modules.
-   Configure Python environment settings.
-   Set security verification options.
-   Configure logging levels and locations.

For more information on the available configuration options, please see the `config.yaml.dist` file.

## Path Handling and Customization

To enhance flexibility and portability, hardcoded paths within SENTINEL's scripts have been replaced with dynamic resolution or configurable environment variables. This allows users to adapt the environment to their specific system layouts without modifying core scripts.

Key environment variables for customization include:

-   `SENTINEL_ROOT`: Automatically determined, but can be explicitly set to the project's root directory.
-   `PYTHON_INSTALL_DIR`: Specifies the base directory for Python installations (e.g., `/opt/python`).
-   `CODE_DIR`: Defines the default directory for code projects (e.g., `/opt/code`).
-   `HOMEBREW_PATH`: Path to the Homebrew executable if installed in a non-standard location.
-   `OPENVINO_SETUPVARS`: Path to the OpenVINO `setupvars.sh` script.
-   `C_TOOLCHAIN_PATH`: Base directory for custom C/C++ toolchains.
-   `WAVETERM_PATH`: Path to the Waveterm executable.
-   `ZFS_BUILD_DIR`, `ZFS_AI_DIR`, `ZFS_CODE_DIR`, etc.: Base directories for ZFS-enforced paths, allowing customization of where specific command types are expected to run.

These variables can be set in your `~/.bashrc.postcustom` or other shell configuration files. If not set, reasonable defaults (often `/opt/` based paths) are used.

## Graceful Fallbacks

Features dependent on specific hardware or external tools (e.g., ZFS, NPU) now include graceful fallbacks. If a required tool or hardware component is not detected, SENTINEL will either provide informative warnings, disable the related functionality, or use a default behavior without causing critical errors.

For example, the `zfssnapshot` function now checks for the presence of the `zfs` command and will inform the user if it's not available, preventing script errors.

## Usage Examples

### Intelligent Command Completion

Type a partial command and press Tab to see context-aware suggestions:
```
$ git ch<TAB>
checkout  cherry-pick  cherry  check-ignore  check-mailmap  check-ref-format
```

With deep completion for arguments and options:
```
$ git checkout <TAB>
main   feature/auth   hotfix/ssl-fix   v2.3.0-RC1   remotes/origin/main
```

### Command Prediction

The system learns from your workflow patterns:
```
$ cd project/
Suggestions based on context:
  npm run dev
  git status
  code .
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
