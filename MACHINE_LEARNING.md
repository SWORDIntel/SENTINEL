# SENTINEL Machine Learning Capabilities

This document provides a comprehensive overview of the machine learning capabilities integrated into the SENTINEL bash framework.

## Table of Contents

- [Overview](#overview)
- [Machine Learning Modules](#machine-learning-modules)
  - [Command Learning & Suggestions](#command-learning--suggestions)
  - [Interactive Chat Assistant](#interactive-chat-assistant)
  - [OpenVINO Acceleration](#openvino-acceleration)
  - [GitHub Star Analyzer](#github-star-analyzer)
  - [Cybersecurity ML Analyzer](#cybersecurity-ml-analyzer)
  - [Using Your Starred Repositories as Tools](#using-your-starred-repositories-as-tools)
- [Technical Implementation](#technical-implementation)
  - [Markov Chain Models](#markov-chain-models)
  - [Local LLM Integration](#local-llm-integration)
  - [Training Process](#training-process)
  - [Vulnerability Detection Techniques](#vulnerability-detection-techniques)
  - [Repository Analysis Techniques](#repository-analysis-techniques)
- [Usage Guide](#usage-guide)
- [Customization](#customization)
- [Future Development](#future-development)

## Overview

SENTINEL implements several machine learning capabilities designed to enhance the bash shell experience:

1. **Automatic command learning** that adapts to your usage patterns
2. **Intelligent command suggestions** based on context and history
3. **Conversational AI assistant** for shell-related queries
4. **Hardware-accelerated inference** when OpenVINO is available
5. **Your GitHub starred repositories as OSINT and security tools**

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
- **Tools identification:** Identifies and categorizes useful tools among your starred repositories
- **Usage recommendations:** Suggests how to use your starred repositories as tools

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

### Cybersecurity ML Analyzer

The Cybersecurity ML Analyzer module provides advanced code scanning and security vulnerability detection using machine learning techniques. It combines traditional pattern matching with ML-powered analysis to identify potential security issues in codebases.

**Key Features:**

- **ML-powered vulnerability detection:** Identifies potential security issues using trained models
- **Pattern-based scanning:** Detects common vulnerability patterns across multiple languages
- **LLM-based code analysis:** Uses local LLMs to perform advanced security reviews
- **Vulnerability database:** Maintains an up-to-date database of known code vulnerabilities
- **Training data generation:** Creates synthetic vulnerable/secure code pairs for model training
- **Anomaly detection:** Identifies unusual code patterns that may indicate security issues
- **GitHub integration:** Can analyze security aspects of starred GitHub repositories
- **Security tools identification:** Categorizes your starred repositories as security tools
- **Tool recommendation:** Suggests appropriate security tools from your stars for specific tasks
- **Command generation:** Provides usage commands for applying security tools to targets

**Components:**

- `sentinel_cybersec_ml.module`: Bash module that provides the shell interface
- `sentinel_cybersec_ml.py`: Core Python implementation for security scanning and analysis
- Models and datasets stored in `~/.sentinel/cybersec/`

**Machine Learning Models:**

- **Vulnerability Classifier:** Random Forest model trained to detect vulnerable code patterns
- **Anomaly Detector:** Isolation Forest model that identifies unusual code constructs
- **Deep Learning Model:** Optional TensorFlow-based neural network for advanced pattern recognition
- **Code Vectorizer:** TF-IDF vectorizer optimized for source code representation

**Example Usage:**

```bash
# Quick security scan of current directory
securitycheck

# Full scan with detailed options
cyberscan ~/my-project --recursive --include=py,js,php

# Update vulnerability database
cyberupdate

# List security tools from your starred repositories
cybersecurity --list-tools

# Suggest tools for a specific security task
cybersecurity --suggest-tools "scan for SQL injection vulnerabilities"

# Use a specific security tool against a target
cybersecurity --use-tool nmap --target example.com
```

**Behavior Notes:**

- Combines multiple analysis techniques for more accurate vulnerability detection
- Uses LLM to generate signatures from vulnerability descriptions
- Clusters similar findings to help identify vulnerability patterns
- Results are saved as JSON for further analysis or reporting
- All processing happens locally to maintain code privacy
- Integrates with GitHub Star Analyzer for repository security analysis
- Aliases are provided for common commands (cyberscan, cyberupdate, etc.)

**Security Features:**

- **HMAC token verification:** All security operations use cryptographic verification
- **Contextual analysis:** Considers surrounding code for better detection accuracy
- **Severity scoring:** Assigns CVSS-compatible severity scores to findings
- **Remediation suggestions:** Provides specific mitigation strategies for each issue
- **Multi-language support:** Covers Python, JavaScript, PHP, Java, C/C++, and more

### Using Your Starred Repositories as Tools

A unique feature of SENTINEL is the ability to leverage your GitHub starred repositories as OSINT and cybersecurity tools, rather than relying on predefined tools. This provides a personalized toolbox that evolves with your interests and needs.

**Key Benefits:**

- **Personalized toolset:** Uses tools you've already identified as useful
- **Self-updating:** Automatically incorporates new repositories you star
- **Context-aware:** Recommends tools based on your usage patterns and current tasks
- **Learning capability:** Improves recommendations over time
- **Comprehensive:** Covers a wide range of OSINT and security capabilities

#### Steps to Setup and Use Your Starred Repositories

1. **Initial setup and repository download:**

   ```bash
   # Install required dependencies
   pip install requests beautifulsoup4 tqdm sklearn numpy

   # Download your starred repositories
   sentinel_gitstar_fetch

   # Analyze repositories and categorize them
   sentinel_gitstar_analyze
   ```

2. **Using repositories as OSINT tools:**

   ```bash
   # List all OSINT tools from your starred repositories
   sentinel_osint --list-tools

   # Suggest OSINT tools for a specific task
   sentinel_osint --suggest-tools "find email addresses for a domain"

   # Use a specific OSINT tool
   sentinel_osint --use-tool theHarvester --target example.com
   ```

3. **Using repositories as security tools:**

   ```bash
   # List security tools by category
   cybersecurity --list-tools

   # Suggest tools for a specific security task
   cybersecurity --suggest-tools "scan for open ports"

   # Use a specific security tool
   cybersecurity --use-tool nmap --target 192.168.1.1
   ```

**Example Workflow:**

1. Star useful GitHub repositories in the browser as you discover them
2. Periodically run `sentinel_gitstar_fetch` to update your local repository database
3. Use the `sentinel_osint` and `cybersecurity` commands to leverage these repositories as tools
4. Review suggestions and apply the best tools for your current task

**Integration with Bash Environment:**

The tool recommendations are integrated into your bash environment, making them available when you need them:

```bash
# When working with an email address, automatic suggestions appear
$ email=user@example.com
$ # Press Tab to see suggested tools for email analysis

# When working with a domain, security scan suggestions appear
$ domain=example.com
$ # Press Tab to see suggested security tools for domain analysis
```

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

### Vulnerability Detection Techniques

The cybersecurity ML module employs a multi-layered approach to vulnerability detection:

1. **Signature-based Detection:** Uses a database of known vulnerability patterns
   - Exact pattern matching using regular expressions
   - Signatures generated from CVE descriptions
   - Language-specific vulnerability patterns
   - Rule severity based on CVSS scores

2. **Machine Learning Classification:**
   - Random Forest classifiers trained on labeled code examples
   - Feature extraction using TF-IDF vectorization of code
   - Dimensionality reduction for efficient processing
   - Confidence scoring based on prediction probabilities
   - Continual learning from new examples

3. **Anomaly Detection:**
   - Isolation Forest models to detect statistical outliers in code
   - Detects unusual coding patterns not seen in training data
   - Particularly effective for zero-day vulnerabilities
   - Unsupervised learning approach requiring no labeled examples
   - Sensitivity adjustable via configuration

4. **Deep Learning Analysis (with TensorFlow):**
   - Sequential models with embedding layers for code understanding
   - LSTM layers for sequential pattern recognition in code
   - Convolutional layers to detect localized vulnerability patterns
   - Handles complex relationships between code elements
   - Transfer learning capabilities from pre-trained models

5. **LLM-based Code Review:**
   - Uses instruction-tuned models for human-like code review
   - Context window allows analysis of surrounding code
   - Produces detailed explanations of vulnerabilities
   - Suggests specific mitigation strategies
   - Zero-shot capabilities for novel vulnerability types

6. **Pattern Matching:**
   - Language-specific regex patterns for common vulnerabilities
   - Targets known dangerous functions and practices
   - Efficient first-pass scanning of large codebases
   - Custom pattern database for organization-specific issues
   - Regular updates from security advisories

7. **Feature Engineering for Code Analysis:**
   - Custom tokenization optimized for source code
   - N-gram analysis to capture code sequences
   - AST-inspired features for structural understanding
   - Variable and function name analysis
   - Control flow pattern recognition

8. **Ensemble Decision Making:**
   - Weighted combination of multiple detection techniques
   - Higher confidence for findings confirmed by multiple methods
   - Decision thresholds configurable via settings
   - False positive reduction through consensus
   - Severity escalation for high-confidence findings

Each layer provides different insights, and the results are combined for a comprehensive security analysis. The modular design allows for disabling specific techniques based on performance requirements or enabling advanced techniques when appropriate hardware is available.

### Repository Analysis Techniques

The repository analysis system employs various techniques to extract useful information from GitHub repositories:

1. **Repository Categorization:**
   - Text-based classification of README content
   - Repository name and description analysis
   - Topic and tag extraction from GitHub metadata
   - Clustering of similar repositories using TF-IDF and K-means
   - ML-based identification of tool repositories vs. library/documentation repositories

2. **Repository Functionality Analysis:**
   - Pattern recognition to identify command-line tools
   - README parsing to extract usage examples
   - Installation command extraction from documentation
   - Identification of input/output types from examples
   - Language and framework detection

3. **Command Generation:**
   - Extraction of command patterns from READMEs
   - Intelligent mapping of parameters to user data
   - Command templating for different use cases
   - Sensitivity analysis for parameters requiring special treatment
   - LLM-powered command construction for complex tools

4. **Tool Recommendation System:**
   - Contextual relevance scoring for repositories
   - Task-based filtering and ranking
   - Usage pattern analysis and personalization
   - Confidence scoring for recommendations
   - Multi-criteria decision process incorporating:
     - Repository popularity (stars, forks)
     - Repository activity (recent commits)
     - Repository documentation quality
     - Previous successful usage

5. **Learning and Improvement:**
   - Feedback loop from successful tool usage
   - Usage pattern tracking for better recommendations
   - Automatic re-categorization as new repositories are starred
   - Progressive refinement of tool categories and functionality mapping

This analysis happens both during the initial repository fetch and analysis, as well as during runtime when recommendations are needed. The system balances pre-computation with on-demand analysis to provide fast, relevant recommendations.

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

**For security scanning:**

1. Use the `securitycheck` command for a quick scan of the current directory
2. For more thorough analysis, use `cyberscan <directory>` with additional options
3. Keep the vulnerability database updated with `cyberupdate`
4. Review scan results for actionable security insights

**For OSINT and security tools:**

1. When faced with a specific OSINT or security task, use `sentinel_osint --suggest-tools` or `cybersecurity --suggest-tools` with a description of your task
2. Review the suggested tools and pick the most appropriate for your needs
3. Use `sentinel_osint --use-tool <tool_name> --target <target>` or `cybersecurity --use-tool <tool_name> --target <target>` to apply the selected tool
4. Follow the suggested commands or setup instructions provided

**Example OSINT workflow:**
```bash
# Find tools to gather information on a specific domain
sentinel_osint --suggest-tools "gather information about example.com"

# Use a recommended tool
sentinel_osint --use-tool dnsrecon --target example.com

# Follow the suggested commands
dnsrecon -d example.com -D /path/to/wordlist.txt -t std
```

**Example security workflow:**
```bash
# Find tools to analyze a potentially malicious file
cybersecurity --suggest-tools "analyze suspicious PDF file"

# Use a recommended tool
cybersecurity --use-tool pdfid --target suspicious_document.pdf

# Follow the suggested commands
pdfid suspicious_document.pdf
```

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

### Cybersecurity Scanner Settings

Configure the cybersecurity scanner by editing `~/.sentinel/cybersec/config.json`:

```json
{
  "detection_threshold": 0.75,
  "analyze_libraries": true,
  "max_file_size": 10485760,
  "ignored_directories": [".git", "node_modules", "__pycache__", "venv"],
  "update_frequency": 604800,
  "api_endpoints": {
    "nvd": "https://services.nvd.nist.gov/rest/json/cves/2.0",
    "github_advisory": "https://api.github.com/advisories"
  },
  "llm_settings": {
    "temperature": 0.1,
    "max_tokens": 1024,
    "top_p": 0.9,
    "top_k": 40,
    "context_size": 4096
  },
  "ml_settings": {
    "model_confidence_threshold": 0.65,
    "anomaly_detection_threshold": -0.5,
    "clustering_epsilon": 0.3,
    "min_cluster_size": 2,
    "use_deep_learning": true,
    "vectorizer_max_features": 10000
  },
  "scan_settings": {
    "max_threads": 4,
    "progress_bar": true,
    "detailed_logging": false,
    "report_format": "text"
  }
}
```

The configuration file allows extensive customization of the ML module's behavior, from detection thresholds to model parameters.

### Repository Tool Settings

Configure the GitHub Star Analyzer tool behavior by editing `~/.sentinel/gitstar/config.json`:

```json
{
  "fetch_settings": {
    "readme_fetch_timeout": 10,
    "max_readme_size": 500000,
    "fetch_description": true,
    "fetch_topics": true
  },
  "analysis_settings": {
    "use_llm": true,
    "min_readme_size": 100,
    "categorize_repositories": true,
    "extract_commands": true,
    "confidence_threshold": 0.6
  },
  "tool_recommendation_settings": {
    "max_suggestions": 5,
    "min_confidence": 0.3,
    "prefer_recently_used": true,
    "prefer_recently_updated": true,
    "boost_highly_starred": true
  }
}
```

## Future Development

Planned enhancements for the machine learning components include:

1. **Improved suggestion quality** with reinforcement learning from user feedback
2. **Expanded language support** for more programming languages and frameworks
3. **Hardware acceleration** optimizations for faster inference
4. **Transfer learning** from public code repositories
5. **Real-time vulnerability scanning** during coding
6. **Integration with CI/CD pipelines** for automated security checks
7. **Collaborative filtering** for command suggestions based on similar user patterns
8. **Advanced visualization** of security findings and relationships
9. **Multi-modal models** that can handle both code and natural language
10. **Enhanced repository intelligence** for better understanding of tool capabilities
11. **Workflow generation** that chains multiple repositories together for complex tasks
12. **Tool combination suggestions** with appropriate flags and options
13. **Automation API** for programmatic access to repository-based tools

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