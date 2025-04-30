# SENTINEL Shared Context Module

The SENTINEL Shared Context Module provides a unified context layer that connects the command learning system and the chat assistant. This integration enables more intelligent, context-aware interactions across SENTINEL's machine learning capabilities.

## Features

- **Unified Context Store**: Maintains a shared understanding of your shell environment and command patterns
- **Command Pattern Learning**: Identifies and stores sequences of related commands
- **Task Detection**: Automatically detects what task you're working on based on command usage
- **Context-Aware Chat**: Enhances the chat assistant with relevant context about your current environment
- **Secure Context Handling**: Uses HMAC verification to ensure context integrity

## Components

1. **Python Context Engine** (`sentinel_context.py`): Core context management system
2. **Bash Integration** (`sentinel_context.sh`): Shell hooks and command interface
3. **Chat Integration** (`sentinel_chat_context.py`): Connects the context to the chat assistant

## Installation

The context module is designed to be integrated with the existing SENTINEL modules:

```bash
# Enable the context module
echo "sentchat/sentinel_context" >> ~/.bash_modules

# Apply patches to sentinel_chat.py
# (Follow instructions in sentinel_chat_patch.py)
```

## Usage

### Command Line Interface

```bash
# Show current context
sentinel_context

# Get detailed context information
sentinel_show_context

# Update context manually
sentinel_update_context

# Get command suggestions
sentinel_smart_suggest <command_prefix>
```

### Shell Aliases

- `ctx`: Show current context
- `ctxshow`: Show detailed context information
- `ctxupdate`: Update context manually
- `suggest`: Get command suggestions

### In Chat Assistant

The context integration adds two new commands to the chat assistant:

- `/context`: Show current shell context
- `/suggest <prefix>`: Get command suggestions

## How It Works

### Context Collection

The module collects context from several sources:

1. **Shell Environment**: Current directory, user, hostname
2. **Command History**: Recent commands and their exit status
3. **Git Information**: Branch, status, and remote repository details
4. **Task Context**: Current detected task based on command patterns

### Command Pattern Detection

The module analyzes command sequences to identify patterns:

1. Records successful command executions
2. Periodically analyzes recent command history
3. Identifies common sequences and tracks their frequency
4. Provides suggestions based on detected patterns

### Context-Aware Chat

The chat assistant is enhanced with context:

1. The system prompt is augmented with relevant context information
2. Command suggestions are tailored to your current environment
3. Responses consider your current task and directory

## Privacy and Security

The context module is designed with privacy in mind:

- All data remains local on your machine
- Sensitive commands (containing passwords, keys, etc.) are filtered
- Context information is protected with HMAC signatures
- You can clear context data at any time

## Configuration

Configuration is stored in the following files:

- `~/.sentinel/context/shared_context.json`: Main context store
- `~/.sentinel/context/command_patterns.json`: Command pattern data
- `~/.sentinel/context/task_context.json`: Task detection data
- `~/.sentinel/context/user_preferences.json`: User-specific preferences

## Integration with Other Modules

### Command Learning System

The context module works with the existing command learning system:

1. Records command patterns for better suggestions
2. Provides additional context to improve suggestion relevance
3. Shares learned patterns between both systems

### Chat Assistant

The chat assistant is enhanced with context:

1. Includes context-aware system prompts
2. Responds with awareness of your current task
3. Suggests commands based on your usage patterns and environment

## Troubleshooting

If you encounter issues with the context module:

1. Check that Python 3 is installed and available
2. Verify that the module is properly enabled in `~/.bash_modules`
3. Check file permissions in the `~/.sentinel/context` directory
4. Reset context data if it becomes corrupted: `rm -rf ~/.sentinel/context/*.json`

## Technical Details

The context module uses:

- JSON for data storage
- HMAC for data integrity verification
- Environment variables for configuration
- Background processing to avoid shell performance impact

For more information on the technical implementation, see the source code comments. 