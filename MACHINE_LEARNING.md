# SENTINEL Machine Learning Capabilities

This document provides a comprehensive overview of the machine learning capabilities integrated into the SENTINEL bash framework.

## Table of Contents

- [Overview](#overview)
- [Machine Learning Modules](#machine-learning-modules)
  - [Command Learning & Suggestions](#command-learning--suggestions)
  - [Interactive Chat Assistant](#interactive-chat-assistant)
  - [OpenVINO Acceleration](#openvino-acceleration)
  - [GitHub Star Analyzer](#github-star-analyzer)
- [Technical Implementation](#technical-implementation)
  - [Markov Chain Models](#markov-chain-models)
  - [Local LLM Integration](#local-llm-integration)
  - [Training Process](#training-process)
- [Usage Guide](#usage-guide)
- [Customization](#customization)
- [Future Development](#future-development)

## Overview

SENTINEL implements several machine learning capabilities designed to enhance the bash shell experience:

1. **Automatic command learning** that adapts to your usage patterns
2. **Intelligent command suggestions** based on context and history
3. **Conversational AI assistant** for shell-related queries
4. **Hardware-accelerated inference** when OpenVINO is available

These capabilities work together to create a more intuitive and efficient terminal experience that continuously improves as you use it.

## Machine Learning Modules

### Command Learning & Suggestions

The command learning system uses Markov chain models to analyze and learn from your command history, offering suggestions based on past patterns.

**Key Features:**

- **Automatic learning:** Records successful commands and continually updates its model
- **Contextual suggestions:** Provides command completions based on what you're typing
- **Privacy-focused:** All data stays local; no remote processing
- **History analysis:** Learns from existing bash history on first run
- **Command frequency tracking:** Maintains statistics on your most used commands

**Components:**

- `sentinel_ml.module`: Bash module that provides the shell interface
- `sentinel_autolearn.py`: Core Python implementation for learning and suggestions
- `sentinel_suggest.py`: Lightweight suggestion engine

**Example Usage:**

```bash
# Get statistics on your most used commands
sentinel_ml_stats

# Manually trigger retraining (though this happens automatically)
sentinel_ml_train
```

**Behavior Notes:**

- The model automatically recompiles on terminal launch to incorporate newly learned commands
- Training happens in the background and should not impact performance
- Command statistics are maintained in `~/.sentinel_stats.json`
- The trained model is stored in `~/.sentinel_model.json`

### Interactive Chat Assistant

The chat assistant provides a conversational interface for shell-related questions, leveraging local LLMs for response generation.

**Key Features:**

- **Context-aware responses:** Understands your current directory, git status, and recent commands
- **Local LLM processing:** Uses llama-cpp-python to run models entirely on your machine
- **Command suggestions:** Can recommend specific commands with explanations
- **Secure command execution:** Allows running suggested commands with HMAC verification
- **Interactive mode:** Provides a REPL for ongoing conversations

**Components:**

- `sentinel_chat.module`: Bash module that provides the shell interface
- `sentinel_chat.py`: The Python implementation of the chat assistant
- LLM models stored in `~/.sentinel/models/`

**Example Usage:**

```bash
# Start interactive chat mode
sentinel_chat

# Ask a direct question without entering interactive mode
sentinel_chat "How do I find large files in this directory?"

# Check the status of the chat module
sentinel_chat_status
```

**Commands within chat:**

- `/help`: Show available commands
- `/exit` or `/quit`: Exit the chat
- `/clear`: Clear the chat history
- `/history`: Show chat history
- `/context`: Show current shell context
- `/execute <command>`: Securely execute a shell command

### OpenVINO Acceleration

When available, SENTINEL can use Intel's OpenVINO framework to accelerate machine learning inference.

**Key Features:**

- **Automatic detection:** Checks if OpenVINO is installed and enabled
- **Hardware acceleration:** Uses available accelerators (CPU, GPU, VPU, etc.)
- **Fallback mechanism:** Gracefully falls back to standard processing if acceleration isn't available

**Requirements:**

- OpenVINO toolkit installed (`pip install openvino`)
- Compatible hardware (Intel CPU, GPU, or Neural Compute Stick)

### GitHub Star Analyzer

The GitHub Star Analyzer module downloads READMEs from starred GitHub repositories and analyzes them using machine learning to categorize repositories and provide intelligent suggestions.

**Key Features:**

- **Automated download:** Fetches READMEs from GitHub starred repositories
- **ML-powered categorization:** Clusters repositories by content similarity 
- **Context-aware search:** Finds repositories matching specific queries
- **Task suggestions:** Recommends repositories for specific tasks
- **Advanced LLM analysis:** Uses local LLM to extract detailed metadata
- **Terminal-based UI:** Intuitive interface for managing repositories

**Components:**

- `sentinel_gitstar.module`: Bash module that provides the shell interface
- `sentinel_gitstar.py`: Core Python implementation for fetching and analyzing repositories
- `sentinel_gitstar_tui.py`: Terminal-based UI for easier interaction
- Repository data stored in `~/.sentinel/gitstar/`

**Example Usage:**

```bash
# Terminal UI (Recommended)
sgtui

# Install all dependencies
sgdeps

# Command-line interface
sentinel_gitstar_fetch <username>
sentinel_gitstar_analyze
sentinel_gitstar_search "text processing"
sentinel_gitstar_suggest "build a REST API with authentication"
sentinel_gitstar_stats
```

**Behavior Notes:**

- Uses TF-IDF vectorization and K-means clustering for repository categorization
- LLM analysis provides detailed insights about repository purpose and features
- All data stays local; no GitHub token is required for public repositories
- Aliases are provided for common commands (sgfetch, sgsearch, sgsuggest, sgstats, sgtui)

## Technical Implementation

### Markov Chain Models

The command learning system uses Markov chains implemented via the `markovify` library:

- **State-based model:** Analyzes command patterns based on previous states
- **Probabilistic generation:** Suggests commands based on statistical likelihood
- **Text-based learning:** Processes command history as text for learning
- **Model serialization:** Saves and loads models as JSON for persistence

### Local LLM Integration

The chat assistant integrates local language models via `llama-cpp-python`:

- **Instruction format:** Uses an instruction-tuned model for better responsiveness
- **Context window:** Maintains conversation history within the context window
- **System prompts:** Uses carefully crafted system prompts for shell-specific knowledge
- **Local processing:** Guarantees privacy by processing all queries locally

### Training Process

The machine learning system employs a multi-stage training process:

1. **Initial learning:** On first run, analyzes existing bash history
2. **Continuous updates:** Records new commands as you use them
3. **Periodic retraining:** Automatically rebuilds the model periodically
4. **Command filtering:** Avoids recording sensitive commands containing passwords or secrets
5. **Serialization:** Saves models for persistence between sessions

## Usage Guide

### Initial Setup

The ML modules are automatically enabled when you install SENTINEL. Dependencies are checked on first run, and you'll be prompted to install any missing packages.

**Required Python packages:**

- `markovify`: For command learning and suggestion
- `numpy`: For numerical operations (optional but recommended)
- `openvino`: For hardware acceleration (optional)
- `llama-cpp-python`: For the chat assistant
- `rich`: For formatted terminal output in the chat assistant

### Daily Usage

**For command suggestions:**

The system works automatically in the background. As you use commands, it learns your patterns. Suggestions appear for registered commands (like `findlarge`, `find_big_dirs`, etc.).

**For the chat assistant:**

1. Launch with `sentinel_chat` or the shortcut `schat`
2. Ask questions in natural language about shell commands, Linux, or system administration
3. Use the special commands (prefixed with `/`) for additional functionality

## Customization

### Command Learning Settings

Edit `~/.sentinel/config.json` to modify behavior:

```json
{
  "learning_rate": 1.0,
  "suggestion_count": 5,
  "min_command_length": 3,
  "excluded_commands": ["passwd", "ssh", "gpg"],
  "retrain_frequency": 50
}
```

### Chat Assistant Settings

Configure the chat assistant by editing `~/.sentinel/chat_config.json`:

```json
{
  "model": "mistral-7b-instruct-v0.2.Q4_K_M.gguf",
  "context_size": 4096,
  "max_tokens": 2048,
  "temperature": 0.7,
  "system_prompt": "You are SENTINEL, a helpful shell assistant..."
}
```

## Future Development

Planned enhancements for SENTINEL's machine learning capabilities:

### Short-term Roadmap

- **Enhanced context awareness:** Better understanding of file system contents and project structure
- **Command chaining suggestions:** Learning and suggesting sequences of related commands
- **Error correction:** Suggesting fixes for incorrect commands
- **Advanced filtering:** More sophisticated filtering of sensitive commands

### Mid-term Roadmap

- **Multi-modal integration:** Visual elements for complex command output interpretation
- **Personalized learning rates:** Adapting learning based on user expertise level
- **Task analysis:** Understanding higher-level tasks from command sequences
- **Command optimization:** Suggesting more efficient alternatives to commonly used commands

### Long-term Vision

- **Workflow automation:** Identifying repetitive sequences and suggesting automation
- **Predictive file operations:** Anticipating file operations based on context
- **Natural language command generation:** Translating plain English requests into command sequences
- **Cross-session context:** Maintaining awareness across different terminal sessions and projects

## Contributing

Contributions to SENTINEL's machine learning capabilities are welcome:

1. **Model improvements:** Enhancing the suggestion and learning algorithms
2. **LLM integration:** Supporting additional model architectures and formats
3. **Acceleration:** Improving performance on various hardware
4. **Prompt engineering:** Refining system prompts for better assistance

## Technical Architecture

```
                   ┌───────────────────┐
                   │  SENTINEL Core    │
                   └───────────────────┘
                           │
                 ┌─────────┼─────────┐
                 │         │         │
        ┌────────▼─────┐ ┌─▼───────┐ ┌─▼──────────┐
        │ Command      │ │ Chat    │ │ Future ML  │
        │ Learning     │ │ System  │ │ Modules    │
        └──────────────┘ └─────────┘ └────────────┘
                │             │            │
        ┌───────▼───────┐ ┌───▼─────┐ ┌────▼─────┐
        │ markovify     │ │ llama-  │ │ OpenVINO │
        │ Model         │ │ cpp     │ │ Runtime  │
        └───────────────┘ └─────────┘ └──────────┘
                │             │            │
        ┌───────▼───────┐ ┌───▼─────┐ ┌────▼─────┐
        │ Command       │ │ User    │ │ Hardware │
        │ History       │ │ Queries │ │ Accel.   │
        └───────────────┘ └─────────┘ └──────────┘
```

This document will be updated as new machine learning capabilities are added to SENTINEL. 