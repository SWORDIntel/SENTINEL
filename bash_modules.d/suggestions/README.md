# SENTINEL Suggestions Module

The SENTINEL Suggestions module provides intelligent command suggestions based on your shell usage patterns. It uses machine learning to analyze your command history and provide relevant suggestions.

## Features

- **Command Auto-Learning**: Learns from your command history automatically
- **Contextual Suggestions**: Recommends commands based on what you're typing
- **Frequency Analysis**: Prioritizes commands you use most often
- **Pattern Recognition**: Identifies common command patterns and sequences
- **Cross-Platform**: Works on both Linux and Windows (with appropriate fixes)

## Technical Implementation

The suggestions system uses a Markov chain model to learn from command history. This allows it to:

1. Analyze sequence patterns in command usage
2. Understand command relationships and common workflows
3. Generate statistically probable next commands
4. Adapt to your unique usage patterns over time

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
   echo "source bash_modules.d/suggestions/init.sh" >> bash_modules
   ```

## Usage

### Getting Command Suggestions

To get a suggestion for a command you're trying to remember:

```bash
sentinel_suggest [partial_command]
```

Examples:
```bash
$ sentinel_suggest git
Suggested commands:
1. git status
2. git pull
3. git push origin master

$ sentinel_suggest find .
Suggested commands:
1. find . -name "*.txt"
2. find . -type f -size +10M
3. find . -mtime -7 -type f
```

### Training the Model

The suggestion model trains automatically based on your command history. However, you can manually trigger a retraining:

```bash
sentinel_train
```

This will:
1. Read your command history
2. Build a new Markov model
3. Save the model for future suggestions

## Configuration

Edit `bash_modules.d/suggestions/config.sh` to customize behavior:

```bash
# Number of command history entries to analyze
SENTINEL_HISTORY_DEPTH=1000

# Number of suggestions to show
SENTINEL_SUGGESTION_COUNT=3

# Path to store the trained model
SENTINEL_MODEL_PATH="$HOME/.sentinel/models/command_model.json"

# Whether to include timestamps in analysis
SENTINEL_USE_TIMESTAMPS=true
```

## Windows Compatibility

When using on Windows:

1. Ensure you've run the Windows Code Fixes: `.\Windows Code Fixes\run_fixes.ps1`
2. Use appropriate path separators in configuration
3. Make sure Python is properly installed and accessible

## Privacy

The suggestions module:
- Only processes your local command history
- Stores models locally on your machine
- Does not send data to external services
- Can be disabled at any time

## Troubleshooting

If suggestions aren't working properly:

1. Check that the module is enabled: `grep suggestions bash_modules`
2. Verify the model file exists: `ls -la ~/.sentinel/models/`
3. Ensure Python dependencies are installed: `pip list | grep markovify`
4. Try regenerating the model: `sentinel_train --force`

## How It Works

1. **Data Collection**: Reads your command history from `.bash_history`
2. **Preprocessing**: Cleans and normalizes command data
3. **Model Training**: Builds a Markov chain model based on command sequences
4. **Suggestion Generation**: Uses the model to predict likely commands given input
5. **Continuous Learning**: Updates the model as you use new commands

## Contributing

Contributions to improve the suggestions system are welcome. Consider:

- Enhancing the prediction algorithm
- Improving cross-platform compatibility
- Adding support for more complex command patterns
- Creating integrations with other shell tools 