# SENTINEL Markov Text Generator

A secure, high-performance Markov chain text generator integrated with the SENTINEL framework. This module uses advanced text analysis and probabilistic models to generate natural-looking text based on input sources.

## Features

- **Multiple Input Sources**: Process text from files, directories, or stdin
- **Security-Focused**: Input validation, file permission controls, and hash verification
- **Advanced Generation**: Adjustable state size and retention parameters
- **Terminal Integration**: Seamless integration with SENTINEL shell environment
- **Command Suggestion**: Generate contextual command suggestions based on shell history
- **Corpus Management**: Add, list, and maintain text corpus with statistics

## Installation

The Markov generator is included with SENTINEL. To ensure all dependencies are installed:

```bash
# Activate the SENTINEL Python environment
source ~/venv/bin/activate

# Install required dependencies
pip install markovify numpy tqdm unidecode
```

Enable the module in SENTINEL:

```bash
# Add the module to your active modules
echo "sentinel_markov" >> ~/.bash_modules

# Source bashrc to load the module
source ~/.bashrc
```

## Usage

### Basic Text Generation

Generate text from a file with default settings:
```bash
sentinel_markov generate -i input.txt
```

### Advanced Options

Generate text with custom parameters:
```bash
sentinel_markov generate -i input.txt -s 3 -c 10 -l 320 -o output.txt
```

Parameters:
- `-i, --input`: Input file path
- `-o, --output`: Output file path
- `-s, --state-size`: Markov chain state size (default: 2)
- `-c, --count`: Number of sentences to generate (default: 5)
- `-l, --max-length`: Maximum sentence length (default: 280)

### Direct Python Script Usage

The Python script can be used directly for more advanced scenarios:

```bash
./markov_generator.py --input input.txt --state-size 3 --count 10 --output output.txt
./markov_generator.py --corpus-dir ./corpus/ --state-size 2
cat input.txt | ./markov_generator.py --stdin --count 5
```

### Corpus Management

Add files to your corpus:
```bash
sentinel_markov corpus file.txt
```

List corpus files:
```bash
sentinel_markov list
```

View corpus statistics:
```bash
sentinel_markov corpus-stats
```

Clean cache and outputs:
```bash
sentinel_markov clean
```

## Technical Details

### Architecture

The generator uses a multi-stage pipeline:
1. **Secure Input Handling**: Validates file permissions and content safety
2. **Text Preprocessing**: Normalizes and improves text quality for model generation
3. **Model Building**: Creates Markov chain models with configurable state size
4. **Text Generation**: Produces output based on probabilistic state transitions
5. **Output Processing**: Filters and formats results for readability

### State Size Explained

The `state_size` parameter controls how many words the model uses for context:

- **State Size 1**: Context of 1 word, more random outputs
- **State Size 2**: Context of 2 words, balanced coherence/creativity
- **State Size 3+**: Larger context, more coherent but less creative

For most applications, a state size of 2-3 provides the best results.

### Security Considerations

The Markov generator implements several security features:

- **Input Validation**: Validates all files before processing
- **Secure File Permissions**: Sets appropriate permissions on corpus and output files
- **Size Limits**: Prevents processing of excessively large files
- **Hash Verification**: Logs file hashes for security auditing
- **Error Handling**: Comprehensive error handling and logging

## Integration with SENTINEL

The Markov generator integrates with other SENTINEL features:

- **Command Prediction**: Uses shell history to suggest commands
- **Context Awareness**: Can use current context for better suggestions
- **Logging System**: Integrates with SENTINEL's logging infrastructure
- **Security Framework**: Uses HMAC verification when available

## Troubleshooting

### Common Issues

- **Missing Python Packages**: Ensure all dependencies are installed
- **Permissions Errors**: Check file permissions in ~/.sentinel/markov/
- **Low-Quality Output**: Try increasing the state size or using larger corpus files

### Logs

Check the logs for detailed error information:
```bash
cat ~/.sentinel/markov_generator.log
```

## License

This component is part of the SENTINEL project and is subject to the same license terms.

## Credits

- Markovify library: https://github.com/jsvine/markovify
- SENTINEL Team 