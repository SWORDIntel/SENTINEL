# SENTINEL: Secure ENhanced Terminal INtelligent Layer

![SENTINEL Logo](https://via.placeholder.com/800x200/0d1117/30a14e?text=SENTINEL)

A hardened, optimized, security-focused shell environment for advanced users, researchers, and security professionals, featuring intelligent context-aware assistance, comprehensive autocomplete, environment management, and cybersecurity capabilities.

## Core Features

- **Comprehensive Security**: HMAC verification for module integrity, permission hardening, and execution sandboxing.
- **Intelligent Command Prediction**: Context-aware suggestions based on history analysis, project context, and statistical modeling.
- **Enhanced Autocomplete**: Full-spectrum autocompletion for:
  - Commands and arguments
  - Directory structure
  - Git operations
  - Project-specific contexts
  - SSH hosts and configurations
  - Docker containers and images
  - Custom-defined snippets

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

- **BLE.sh Integration**: Enhanced interactive experience via BLE.sh.
- **FZF Integration**: Secure, interactive fuzzy finding with BLE.sh and SENTINEL enhancements.
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

Intelligent autocomplete for:

- Commands and parameters
- Directory structure
- Custom snippets and templates
- Project-specific contexts
- Git commands and branches
- Docker containers and services
- SSH hosts and configurations
- Package management (npm, pip, apt)

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

- `@autocomplete status` or `sentinel_config_reload` for diagnostics
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

- Bash 4.0+
- Python 3.6+ (with venv support)
- Git 2.20+
- Optional: fzf, ripgrep for enhanced functionality

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Documentation

- [SENTINEL Documentation](https://docs.sentinel-framework.org)
- [Module Development Guide](docs/modules.md)
- [Security Considerations](docs/security.md)
