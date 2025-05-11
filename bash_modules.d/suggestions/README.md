# SENTINEL Modular Autocomplete System

The SENTINEL Autocomplete System has been redesigned with a modular architecture to improve:

- Maintainability
- Debugging capabilities
- Extensibility
- Security

## Module Structure

The system is organized into the following modules:

- **autocomplete.module**: Main orchestration module
- **logging.module**: Centralized logging system with log rotation and levels
- **ble_manager.module**: BLE.sh installation, configuration, and management
- **hmac.module**: Security module for cryptographic functions
- **snippets.module**: Secure command snippet storage and expansion
- **fuzzy_correction.module**: Intelligent command correction
- **command_chains.module**: Command prediction based on usage patterns
- **project_suggestions.module**: Context-aware project suggestions

## Core Features

1. **Centralized Logging System**
   - Standardized logging across all modules
   - Log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
   - Automatic log rotation
   - Log retention policies
   - Console output for high-priority messages

2. **BLE.sh Integration**
   - Automatic installation and configuration
   - Robust error handling and recovery
   - Performance optimizations
   - Fallback mechanisms when BLE.sh isn't available

3. **Secure HMAC Verification**
   - Cryptographically signed tokens and snippets
   - Protection against tampering
   - Secure key management

4. **Intelligent Command Correction**
   - Suggests corrections for mistyped commands
   - Levenshtein distance calculations
   - Quick fix commands (`!!:fix`)

5. **Context-Aware Suggestions**
   - Project type detection (Python, Node.js, Rust, etc.)
   - Framework-specific suggestions
   - Directory context awareness

6. **Command Chain Prediction**
   - Predicts likely next commands
   - Based on command usage patterns
   - Quick execution with `!!:next`

7. **Secure Snippet Management**
   - Cryptographically verified snippets
   - Protection against accidental or malicious changes
   - Easy snippet management

## Usage

The primary interface remains the same with some enhancements:

- `@autocomplete`: Show help
- `@autocomplete status`: Show system status
- `@autocomplete fix`: Fix common issues
- `@autocomplete reload`: Reload BLE.sh
- `@autocomplete install`: Force reinstall BLE.sh
- `@autocomplete logs [component] [lines]`: View recent logs

## Logging Usage

The logging module provides powerful functions for standardized logging:

```bash
# Basic logging functions by level
sentinel_log_debug "component" "Debug message"
sentinel_log_info "component" "Info message"
sentinel_log_warning "component" "Warning message"
sentinel_log_error "component" "Error message"
sentinel_log_critical "component" "Critical message"

# View recent logs
sentinel_show_logs "component" 50  # Show last 50 lines
```

## BLE.sh Management

The BLE.sh manager provides tools for working with BLE.sh:

```bash
# Check BLE.sh status
sentinel_blesh_status

# Reload BLE.sh
sentinel_reload_blesh

# Fix common issues
sentinel_fix_blesh

# Manual installation
sentinel_install_blesh
```

## Legacy Support

The previous monolithic version is still available in legacy mode:

```bash
@autocomplete --legacy-mode
```

## Extending

To create a new module:

1. Create a file named `your_feature.module` in the suggestions directory
2. Follow the module template pattern
3. Add the module to the loading list in `autocomplete.module`

## Security Considerations

The modular design uses HMAC verification to ensure integrity of:

- Stored snippets
- Command corrections
- Secure tokens

This helps prevent tampering and reduces the risk of command injection attacks.

## Module Dependencies

The modules have the following dependency chain:

```
logging.module <- ble_manager.module <- hmac.module <- [all other modules]
               |
               \-- autocomplete.module
```

The logging module must be loaded first as all other modules depend on it for logging.

## Features

- PowerShell-like greyed-out suggestions that appear as you type
- Right arrow to accept suggestion
- History-based autocompletion
- Improved tab completion behavior
- Command category recognition
- Context-aware suggestions
- Smart parameter completion
- Custom snippet expansion
- Project-specific suggestions based on language/framework detection
- Fuzzy command correction
- Command chain prediction
- HMAC-signed security tokens

## Dependencies

- **ble.sh** (Bash Line Editor) - Automatically installed if not present
- **bash** - Requires Bash 4.0+
- **openssl** - Used for HMAC token generation

## Security Features

The autocomplete system includes several security enhancements:

1. HMAC-signed tokens for secure operations
2. Cryptographic verification of command snippets
3. Enhanced TLS configuration for security-related command snippets
4. Path traversal prevention in utilities

## Troubleshooting

If autocomplete isn't working as expected:

1. Run `@autocomplete status` to check the system status
2. Run `@autocomplete fix` to fix common issues
3. Close and reopen your terminal
4. If still not working, run `@autocomplete install` to reinstall ble.sh

## Project-Specific Suggestions

The system automatically detects many project types including:

- Node.js (with framework detection for React, Next.js, etc.)
- Python (with framework detection for Django, Flask, FastAPI, etc.)
- Rust (with workspace, binary/library detection)
- Go
- C/C++ (with build system detection)
- Java/Kotlin (with Maven/Gradle detection)
- Docker

Each project type gets customized command suggestions relevant to that environment.

## Implementation Notes

- All modules use proper error handling
- Background operations are carefully managed to prevent hangs
- Directory permissions are enforced for security
- Each module can function independently if needed
- Fallbacks are provided when ble.sh isn't available 