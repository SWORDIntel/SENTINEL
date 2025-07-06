# SENTINEL: Secure ENhanced Terminal INtelligent Layer

![SENTINEL Logo](https://via.placeholder.com/800x200/0d1117/30a14e?text=SENTINEL)

A hardened, optimized, security-focused shell environment for advanced users, researchers, and security professionals, featuring intelligent context-aware assistance, comprehensive autocomplete, environment management, and cybersecurity capabilities.

## Core Features

- **Comprehensive Security**: HMAC verification for module integrity, permission hardening, and execution sandboxing.
- **Intelligent Command Prediction**: Context-aware suggestions based on history analysis, project context, and statistical modeling.
- **Enhanced Autocomplete**: A hybrid system providing robust autocompletion:
  - For the main `sentinel` command and its Bash-based subcommands: Uses standard Bash completion (`bash-completion` package).
  - For Python-based subcommands and scripts: Uses `argcomplete` for rich, context-aware completions.
  - Covers:
    - Commands, arguments, and options.
    - File paths and directory names.
    - Dynamic suggestions based on context (e.g., available modules).
- **Virtual Environment Management**: Automatic Python virtual environment detection, switching, and dependency tracking.
- **Performance Optimization**: Lazy loading, dependency-based module system, and caching to maintain a responsive terminal.

## Key Components

### Security Focus

- **HMAC Module Verification**: All modules are verified via HMAC to prevent unauthorized modifications.
- **Permissioned File Operations**: Strict permission controls on all files (600/700).
- **Logging**: Comprehensive logging with rotation for security auditing.
- **Safe Execution**: Sandboxed command execution and preview when needed.

### Intelligent Assistance

- **Context-Aware Suggestions**: Commands, arguments, and options based on current context:
  - Directory contents
  - Project type
  - Recent commands
  - File contents
  - Command chains (statistical analysis of command sequences)

- **Error Correction**: Automatic correction for common typos and mistakes.
- **Command Completion**: Multi-level completion with preview for complex operations.

### Advanced Shell Environment

- **Standard Bash Completion**: Integrated with the `bash-completion` framework for robust and performant completions.
- **`argcomplete` for Python Scripts**: Python-based tools leverage `argcomplete` for detailed and dynamic argument completion.
- **FZF Integration**: Secure, interactive fuzzy finding (Note: If FZF's completion bindings were tied to BLE.sh, they may need review).
- **Module System**: Dependency-aware module loading with lazy initialization.
- **Custom Prompts**: Contextual, information-rich prompts with git status and environment indications.

## Performance Optimizations

### Centralized Configuration Caching System

- **Cached Configuration**: All configuration files are cached in `${HOME}/cache/`
- **Performance Impact**: Up to 85% reduction in load time for complex configurations
- **Cache Validation**: Automatic MD5 hash verification to detect changes
- **Configurable Retention**: Time-based cache expiration settings
- **Toggle via `SENTINEL_CONFIG_CACHE_ENABLED=1`**

### Benefits:

- **Faster Shell Startup**: Eliminates repeated file parsing overhead
- **Reduced Disk I/O**: Only reads configurations when changed
- **Memory Efficiency**: Shared cache across processes
- **Variable Tracking**: Identifies which variables were set by which file

### Optimized Module Loading

- **Dependency-Aware Loading**: Loads modules in correct dependency order
- **Lazy Loading**: Modules load only when needed
- **Path Caching**: Cached module lookup paths for faster initialization
- **Parallel Loading**: Multi-threaded initialization where possible
- **Configurable via `SENTINEL_MODULE_CACHE_ENABLED=1`**

### Benefits:

- **Up to 70% Faster Loading**: Dramatic reduction in shell initialization time
- **Selective Loading**: Only loads what is needed for specific operations
- **Reduced Resource Usage**: Minimizes RAM and CPU impact during startup
- **Improved Reliability**: Dependencies handled correctly every time

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/sentinel.git
cd sentinel

# Run the installer
bash install.sh

# Ensure dependencies for autocompletion are met:
# 1. bash-completion: Usually installed via your system's package manager
#    (e.g., sudo apt-get install bash-completion). The install.sh script
#    will attempt to place the sentinel completion file in the correct directory.
# 2. argcomplete (for Python script completions):
#    Install via pip: pip install argcomplete --user
#    Or system-wide: sudo apt-get install python3-argcomplete (Debian/Ubuntu)
#    The install.sh will provide guidance.

# Restart your shell or source the configuration
source ~/.bashrc
```

## Module Configuration

Enable specific modules for customized functionality:

```bash
# Enable modules in SENTINEL
vi ~/.bash_modules

echo "sentchat/sentinel_context" >> ~/.bash_modules
echo "sentchat/sentinel_ml_enhanced" >> ~/.bash_modules

# Reload configuration
source ~/.bashrc
```

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

### Configuration and Customization

All settings are managed in `${HOME}/config.sh`.

#### Modules

Toggle modules on/off through environment variables or use the TUI:

```bash
# Enable specific modules
export SENTINEL_GITSTAR_ENABLED=1
export SENTINEL_ML_ADVANCED=1

# Reload and apply settings
sentinel_config_reload
```

#### Configuration Options

- Enable/disable modules (e.g., `SENTINEL_FZF_ENABLED=1`)
- Set Python environment settings
- Configure security verification
- Set logging levels and locations

##### Cache Configuration:
- `SENTINEL_CONFIG_CACHE_ENABLED=1` - Master toggle for config caching
- `SENTINEL_CONFIG_FORCE_REFRESH=0` - Force rebuild all caches
- `SENTINEL_CONFIG_VERIFY_HASH=1` - Verify cache integrity with MD5
- `SENTINEL_CONFIG_CACHE_RETENTION_DAYS=30` - Auto-cleanup old caches

##### Module System:
- `SENTINEL_MODULE_DEBUG=0` - Show detailed module loading info
- `SENTINEL_MODULE_AUTOLOAD=1` - Auto-load required dependencies
- `SENTINEL_MODULE_CACHE_ENABLED=1` - Enable module path caching
- `SENTINEL_MODULE_VERIFY=1` - Security verification for modules

#### Configuration UI

```bash
./sentinel_toggles_tui.py
```

#### Migrating Configuration

To transfer configuration from older versions:

```bash
bash ~/Documents/GitHub/SENTINEL/bash_modules.d/migrate_config.sh
```

## Major Components

### Autocomplete System

SENTINEL utilizes a hybrid autocompletion system:

-   **Bash Completion (`sentinel-completion.bash`):**
    -   Handles completions for the main `sentinel` command, its global options (e.g., `--verbose`, `--config`), and any subcommands implemented directly in Bash (e.g., `sentinel module list`).
    -   Provides file/directory completion for arguments expecting paths.
    -   Can offer dynamic completions based on context (e.g., listing available modules for `sentinel module load`).
    -   This script is managed by the standard `bash-completion` framework.

-   **`argcomplete` for Python Scripts:**
    -   Python-based subcommands or tools (e.g., `sentinel process` which calls `sentinel_process.py`, or scripts in `contrib/`) use `argparse` for argument definition and `argcomplete` for providing completions.
    *   This allows for rich, type-aware, and choice-aware completions directly from the Python scripts' argument definitions.
    *   To enable this, Python scripts must include the `PYTHON_ARGCOMPLETE_OK` marker and call `argcomplete.autocomplete(parser)`.

This system ensures performant and relevant completions across the entire SENTINEL framework. Snippet functionality previously tied to `ble.sh` has been disabled as part of this refactor; a new snippet engine would need to be implemented if desired.

### Context-Aware Intelligence

Automatic context detection for:

- Project type (Python, Node.js, Docker, etc.)
- Git repository status
- Directory contents and relevance
- Recent command patterns
- Terminal dimensions and capabilities

Commands:
- `sentinel_context` - Show context
- `sentinel_show_context` - Detailed info
- `sentinel_update_context` - Manual update

### Command Chain Prediction

Statistically analyze your command sequences to predict next commands:

```bash
$ git add .
Next likely command: git commit -m "..."
$ docker build -t myapp .
Next likely command: docker run -p 8080:8080 myapp
```

### Markov Chain Command Generation

Generate command suggestions and documentation using Markov models trained on your command history and documentation sources.

Usage: `sentinel_markov generate -i <input> -o <output>`

### Machine Learning Enhancements

Train on your workflow patterns to improve suggestions and automation with:
- Command frequency analysis
- Time-based usage patterns
- File access correlations
- Project-specific command sets

Example: `sentinel_ml_stats`, `sentinel_ml_train`

### LLM Chat Integration

Built-in terminal-based chat system with:
- Context-aware assistance
- Command proposal and execution

Example: `sentinel_chat`, `/help`, `/context`, `/execute <cmd>`

### Git Repository Intelligence

Enhanced git operations with:
- Repository statistics and insights
- Intelligent branch management
- Commit analytics

Example: `sgtui`, `sentinel_gitstar_fetch`, `sentinel_gitstar_analyze`

## Advanced Configuration

- Edit `${HOME}/config.json`, `chat_config.json`, `cybersec/config.json`, `gitstar/config.json` for advanced settings.
- Custom prompts: Configure PS1/PS2 variables in bashrc.postcustom

## Security Features

- HMAC validation for all module loading
- Restricted file permissions (600/700)
- Input validation for all external sources
- Sandboxed command evaluation

## Troubleshooting

- `sentinel_config_reload` for diagnostics.
- To debug Bash completions, you can use `set -x` in your shell before attempting a completion, or add echo statements to `sentinel-completion.bash`.
- For `argcomplete` issues with a Python script, ensure the script is executable, has the `PYTHON_ARGCOMPLETE_OK` marker, calls `argcomplete.autocomplete()`, and is registered (e.g., via `eval "$(register-python-argcomplete your_script.py)"` or global `argcomplete` activation). Check for errors when running the Python script directly.
- Check logs: `sentinel_show_logs "component" 50`
- Check error logs: `cat ~/logs/errors-$(date +%Y%m%d).log`
- Reset context: `rm -rf ${HOME}/context/*.json`
- Try restarting the shell session
- Clear caches: `sentinel_cache_clear`
- Clear configuration cache: `rm -rf ${HOME}/cache/config/*.cache`

## Contributing

Contributions are welcome! To add new modules:

```bash
# SENTINEL - My Module
SENTINEL_MODULE_DESCRIPTION="Description of my module"
SENTINEL_MODULE_VERSION="1.0.0"
SENTINEL_MODULE_DEPENDENCIES="logging config_cache"

# Module implementation
function my_module_command() {
    # Implementation here
}

# Export functions
export -f my_module_command
```

## Requirements

- Bash 4.0+ (for `bash-completion` and the main shell)
- `bash-completion` package (standard Linux/macOS utility)
- Python 3.6+ (with venv support)
- `argcomplete` Python package (for Python script autocompletion)
- Git 2.20+
- Optional: fzf, ripgrep for enhanced functionality

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## Documentation

- [SENTINEL Documentation](https://docs.sentinel-framework.org)
_([Module Development Guide](docs/modules.md) - Note: This file was referenced but not found in the original repository structure.)_
_([Security Considerations](docs/security.md) - Note: This file was referenced but not found in the original repository structure.)_

## Developer Guide: Adding/Modifying Autocompletions

SENTINEL uses a hybrid autocompletion system. Understanding its components is key to extending it.

### 1. Core Architecture

*   **`sentinel-completion.bash`**: This script (typically installed to `/usr/share/bash-completion/completions/sentinel` or a similar user-local path) handles completions for the main `sentinel` command, its global options, and any subcommands implemented directly as Bash functions within the main `sentinel` script.
*   **`argcomplete`**: Python scripts (especially those in `contrib/` or those acting as implementations for `sentinel` subcommands like `sentinel process`) use the `argcomplete` library. This allows Python scripts to define their own completions based on their `argparse` definitions.

### 2. Modifying Bash Completions (`sentinel-completion.bash`)

The `sentinel-completion.bash` script contains a main completion function, typically `_sentinel_completions`.

*   **Location**: Find this script in the SENTINEL source or its installed location.
*   **Structure**:
    *   The function uses Bash built-ins like `compgen` and helper variables like `COMP_WORDS`, `COMP_CWORD`, `cur`, `prev`.
    *   The `_get_comp_words_by_ref` function (often included or sourced) is useful for robustly parsing words, especially those containing `=`,`:`.
    *   A central `case "$cmd"` block (where `cmd` is the current subcommand) dispatches to logic for that subcommand.
*   **Adding a New Bash Subcommand (e.g., `sentinel newbashcmd`)**:
    1.  Add `"newbashcmd"` to the `subcommands` array in `_sentinel_completions`.
    2.  Add a new case to the main `case "$cmd" in ... esac` block:
        ```bash
        newbashcmd)
            # Logic for completing args for newbashcmd
            # Example: complete from a list of actions
            if [[ "$cword" -eq 2 ]]; then # Assuming sentinel newbashcmd <action>
                local actions="action1 action2"
                COMPREPLY=( $(compgen -W "${actions}" -- "$cur") )
            # Add more logic for further arguments/options
            fi
            ;;
        ```
*   **Adding Options to a Bash Subcommand**:
    *   Locate the `case` block for that subcommand.
    *   If completing an option (e.g., `if [[ "$cur" == -* ]]; then`), add your new option to the `compgen -W "..."` list for that subcommand's option completions.
    *   If the option takes an argument, add logic to complete that argument when `prev` is your new option.
*   **Dynamic Completions**: You can call other shell commands or read files within your completion logic to generate `COMPREPLY` dynamically. For example, `sentinel module unload` reads from `/tmp/sentinel_loaded_modules.txt`.
*   **File/Directory Completions**: Use the `_filedir` function (provided by `bash-completion`).

### 3. Enabling `argcomplete` for Python Scripts

For Python scripts (e.g., new tools in `contrib/` or scripts that implement a `sentinel` subcommand):

1.  **Use `argparse`**: Ensure your Python script uses `argparse` to define its command-line arguments.
    ```python
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--my-option", choices=["a", "b"])
    # ... other arguments
    ```
2.  **Add `PYTHON_ARGCOMPLETE_OK` Marker**: Place this comment at the top of your Python script:
    ```python
    #!/usr/bin/env python3
    # PYTHON_ARGCOMPLETE_OK
    ```
3.  **Import and Call `argcomplete`**:
    ```python
    import argcomplete
    # ... (define your parser) ...
    argcomplete.autocomplete(parser)
    args = parser.parse_args()
    ```
    Call `argcomplete.autocomplete(parser)` *before* `parser.parse_args()`.
4.  **Ensure Script is Executable**: `chmod +x your_script.py`.
5.  **Registration (for testing/development)**:
    *   Run `eval "$(register-python-argcomplete your_script.py)"` in your shell.
    *   The `install.sh` script should handle advising users to install `argcomplete` system-wide or for the user, which often enables these completions automatically without manual registration for every script if global completion is active.
6.  **Integration with `sentinel` main command (if applicable)**:
    *   If your Python script is called by the main `sentinel` Bash script (e.g., `sentinel process` calls `sentinel_process.py`), the `sentinel-completion.bash` script should "step aside" when it detects that the `process` subcommand is being completed for its options. It typically does this by returning empty `COMPREPLY` for option arguments of `process`, allowing `argcomplete`'s hooks to take over.
    *   Ensure the `sentinel` script calls the Python script directly (e.g., `./path/to/script.py "$@"`) rather than via `python ./path/to/script.py "$@"`, as `argcomplete` often relies on the executable name in `COMP_LINE`.

By following these guidelines, developers can extend SENTINEL's autocompletion capabilities effectively, maintaining a consistent and helpful user experience.
