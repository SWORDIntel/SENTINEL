# SENTINEL Chat Module

The SENTINEL Chat module provides an interactive, AI-powered conversational assistant for your shell environment. It offers context-aware responses to shell questions, command suggestions, and shell environment assistance.

## Features

- **Conversational Shell Assistant**: Natural language interface for shell questions
- **Context-Aware Responses**: Understands your current directory, environment, and recent commands
- **Command Suggestions**: Provides command examples with explanations
- **Environment Help**: Assists with configuration and troubleshooting
- **Security-Focused**: Local processing of queries with privacy controls

## Installation

### Prerequisites

- Python 3.7 or higher
- Virtual environment (recommended)

### Setup

1. Ensure you have activated your Python virtual environment:
   ```bash
   source .venv/bin/activate  # Linux/macOS
   .\.venv\Scripts\Activate.ps1  # Windows PowerShell
   ```

2. Install required dependencies:
   ```bash
   pip install markovify numpy 
   ```

3. Enable the module in your SENTINEL environment:
   ```bash
   echo "source bash_modules.d/sentchat/init.sh" >> bash_modules
   ```

## Usage

Start the chat interface:
```bash
sentinel chat
```

### Available Commands

Inside the chat REPL, you can use these commands:

- `/help` - Show available commands
- `/exit` or `/quit` - Exit the chat
- `/clear` - Clear the chat history
- `/history` - Show chat history
- `/context` - Show current shell context
- `/execute <command>` - Securely execute a shell command

## Examples

```
$ sentinel chat
Welcome to SENTINEL Chat! How can I help you today?

> How do I find large files in this directory?
You can use the SENTINEL findlarge function to locate large files:

findlarge [size_in_MB] [directory]

Example: findlarge 100 .
This will find files larger than 100MB in the current directory.

> /context
Current directory: /home/user/projects
Shell: bash
User: user
Recent commands:
- ls -la
- cd projects
- git status

> How can I search for text in multiple files?
For searching text across multiple files, you can use:

fgrep <filename_pattern> <search_term>

This uses the SENTINEL fgrep function to find files containing the search term.
Alternatively, you can use: grep -r "search term" .
```

## Machine Learning Features

### Command Learning

The assistant uses a Markov model to learn from:
- Your command history (with consent)
- Common shell patterns
- Specialized domain knowledge

This allows it to provide contextually appropriate suggestions that improve over time.

### Privacy Considerations

By default, the chat assistant:
- Processes queries locally when possible
- Does not permanently store your command history
- Requires explicit permission for advanced features

## Customization

You can customize the behavior by editing `bash_modules.d/sentchat/config.sh`:

```bash
# Example customization
SENTINEL_CHAT_HISTORY_SIZE=100  # Number of chat messages to remember
SENTINEL_CHAT_AUTO_CONTEXT=true  # Automatically provide context
```

## Troubleshooting

If you encounter issues:

1. Ensure your Python environment is properly activated
2. Check that dependencies are installed: `pip list | grep -E 'markovify|numpy'`
3. Verify the module is enabled: `grep sentchat bash_modules`
4. For persistent issues, try regenerating the command model: 
   ```bash
   rm ~/.sentinel/models/command_model.json
   sentinel_train  # This will rebuild the model
   ```

## Contributing

Contributions to improve the SENTINEL Chat module are welcome. Please consider:

- Adding new question-answer pairs to improve response quality
- Enhancing the command suggestion algorithm
- Implementing additional shell integrations 