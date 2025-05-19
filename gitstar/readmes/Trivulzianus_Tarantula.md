# Tarantula Web Security Scanner

![SQL Injection Detection](SQLi.png)

> **⚠️ DISCLAIMER: This is a proof of concept and educational tool only.**
> 
> This software is provided for educational and research purposes only. The author is not responsible for any misuse or damage caused by this program. Use responsibly and only on systems you own or have explicit permission to test.

Tarantula is an advanced web security scanner that combines automated crawling with AI-powered vulnerability detection. It uses Selenium for dynamic web crawling and OpenAI's GPT models for intelligent vulnerability analysis.

## Important Notice

This tool is:
- A proof of concept demonstrating AI-powered security scanning
- Intended for educational purposes only
- Not intended for production use
- Not responsible for any unauthorized testing or damage

**By using this tool, you agree that:**
- You will only use it on systems you own or have explicit permission to test
- You understand and accept all risks associated with security testing
- You will not use it for any malicious purposes
- The author is not liable for any misuse or damage caused by this tool

## Features

- **Dynamic Web Crawling**: Automatically discovers and maps web application endpoints
- **AI-Powered Analysis**: Uses OpenAI's GPT models to identify potential vulnerabilities
- **Intelligent Payload Generation**: Creates context-aware test payloads
- **Real-time Monitoring**: Live feedback on scanning progress
- **Comprehensive Reporting**: Detailed vulnerability reports with evidence
- **User-Friendly GUI**: Easy-to-use interface for controlling the scanning process

## Prerequisites

- Python 3.8 or higher
- Chrome browser installed
- OpenAI API key
- Internet connection

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/tarantula.git
cd tarantula
```

2. Install required dependencies:
```bash
pip install -r requirements.txt
```

3. Configure your OpenAI API key:
   - Launch the application
   - Enter your OpenAI API key in the GUI
   - Click "Save" to store it securely

## Usage

1. **Starting the Scanner**:
   - Run `python Tarantula.py`
   - The GUI will launch automatically

2. **Basic Workflow**:
   - Enter the target domain when prompted
   - Click "Parse Sitemap" to begin crawling
   - Wait for the sitemap parsing to complete
   - Click "Start Testing" to begin vulnerability scanning
   - Monitor progress in the GUI
   - View results in the scan results table

3. **Controls**:
   - Parse Sitemap: Initiates the crawling process
   - Start Testing: Begins vulnerability scanning
   - Stop: Halts the current scanning process
   - Clear Logs: Clears the output window
   - Copy Selected: Copies selected results to clipboard

## Configuration

The scanner can be configured through the GUI:
- Max Iterations: Control the depth of scanning
- API Key: Manage your OpenAI API key
- Target Domain: Set or change the target website

## Output

The scanner provides:
- Real-time scanning progress
- Detailed vulnerability findings
- Evidence of discovered issues
- Confidence levels for each finding
- Exportable results

## Security Considerations

- The scanner stores your OpenAI API key locally in `config.txt`
- The config file is excluded from version control
- All sensitive data is handled securely
- The scanner respects robots.txt and rate limiting

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenAI for providing the GPT API
- Selenium for web automation capabilities
- The open-source security community for inspiration and tools

## Support

For issues, feature requests, or questions, please open an issue in the GitHub repository. 