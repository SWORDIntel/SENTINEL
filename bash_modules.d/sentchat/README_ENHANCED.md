# SENTINEL Enhanced ML Features

The SENTINEL Enhanced ML Module provides advanced machine learning capabilities that build upon the core ML features. These enhancements include predictive command chains, sophisticated task detection, and natural language understanding.

## Features

### 1. Predictive Command Chains

The command chain prediction system learns from your command sequences and provides intelligent suggestions:

- **Transition Analysis**: Learns which commands typically follow each other
- **Context-Aware Suggestions**: Considers your current directory and task context
- **Error Recovery**: Suggests corrections for failed commands
- **Task-Specific Chains**: Identifies command sequences related to specific tasks

### 2. Advanced Task Detection

The task detection system automatically identifies what you're working on:

- **Project Recognition**: Detects project types based on file structure
- **Command Pattern Analysis**: Identifies tasks based on command usage patterns
- **File Context Integration**: Uses current directory contents for better task detection
- **Task History Tracking**: Maintains history of your task transitions

### 3. Natural Language Understanding

The NLU system translates natural language into shell commands:

- **Command Translation**: Converts natural language queries to shell commands
- **Script Generation**: Creates full bash scripts from task descriptions
- **Command Explanation**: Explains what shell commands do in plain language
- **Learning from Feedback**: Improves translations based on your feedback

## Usage

### Command Chain Prediction

```bash
# Get predictions for what might follow your current command
sentinel_predict "git"

# Get suggestions for fixing a failed command
sentinel_fix "apt-get intall nginx"
```

### Task Detection

```bash
# Detect your current task
sentinel_task detect

# Get information about the current project
sentinel_task project

# View task history
sentinel_task history

# Get task suggestions
sentinel_task suggest

# Get details about a specific task
sentinel_task info "python_dev"

# Teach the system about a task
sentinel_task learn "web_deployment" "nginx,docker,docker-compose"
```

### Natural Language Understanding

```bash
# Translate a natural language query to a shell command
sentinel_translate "find all log files larger than 100MB"

# Generate a shell script from a description
sentinel_script myscript.sh "A script that backs up all MySQL databases, compresses them, and uploads to S3"

# Explain what a shell command does
sentinel_explain "find /var/log -type f -size +100M -exec ls -lh {} \;"
```

## Aliases

For convenience, the following aliases are provided:

- `spred`: Shorthand for `sentinel_predict`
- `sfix`: Shorthand for `sentinel_fix`
- `stask`: Shorthand for `sentinel_task`
- `strans`: Shorthand for `sentinel_translate`
- `sscript`: Shorthand for `sentinel_script`
- `sexplain`: Shorthand for `sentinel_explain`

## Integration with Other Modules

The Enhanced ML Module integrates with:

- **Context Module**: Shares context information for better predictions
- **Command Learning System**: Builds upon the basic command learning features
- **Chat Assistant**: Provides task awareness and command suggestions to the chat interface

## Technical Details

### Command Chain Prediction

The chain prediction system uses multiple algorithms:

1. **Transition Statistics**: Tracks which commands typically follow others
2. **Markov Models**: Builds probabilistic models of command sequences
3. **Task-Specific Patterns**: Learns command patterns tied to specific tasks
4. **Error Pattern Matching**: Identifies common error-correction sequences

### Task Detection

Task detection employs several methods:

1. **File Pattern Matching**: Identifies project types from directories and files
2. **Command Pattern Analysis**: Recognizes tasks from command usage
3. **Project Profiling**: Builds profiles of known projects over time
4. **Task Transition Analysis**: Tracks how you switch between different tasks

### Natural Language Understanding

The NLU system combines pattern matching and machine learning:

1. **Intent Recognition**: Matches queries to known command intents
2. **Parameter Extraction**: Identifies key parameters in natural language
3. **Local LLM Inference**: Uses local language models for translation
4. **Feedback Learning**: Improves over time based on your feedback

## Requirements

The Enhanced ML Module requires:

- Python 3.7 or higher
- Required packages: numpy, markovify
- Optional packages for advanced features: llama-cpp-python

## Installation

To enable these features:

```bash
# Make sure files are executable
chmod +x contrib/sentinel_chain_predict.py
chmod +x contrib/sentinel_task_detect.py
chmod +x contrib/sentinel_nlu.py

# Enable the module
echo "sentchat/sentinel_ml_enhanced" >> ~/.bash_modules

# Install dependencies for full functionality
pip install numpy markovify llama-cpp-python
```

## Troubleshooting

If you encounter issues:

1. Check that Python 3 is installed and available
2. Verify that the required Python packages are installed
3. Ensure the script files exist in the contrib directory and are executable
4. Check the log output for specific error messages 