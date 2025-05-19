# ParamFetch

ParamFetch is a tool designed for extracting links from web pages, filtering them based on URL parameters, checking their validity, and saving the valid links to a text file (`parameter.txt`). It is useful for penetration testers, security researchers, and anyone looking to analyze URLs and parameters on target websites.

## Features

- **Link Extraction**: Extracts all links from a web page.
- **Link Filtering**: Filters links based on specified URL parameters.
- **Link Validation**: Verifies the validity of extracted links by checking their HTTP response status.
- **Result Saving**: Saves valid links to a text file (`parameter.txt`).
- **Interactive Interface**: Simple and easy-to-use command-line interface for input.

## Requirements

- Python 3.x
- The following Python libraries:
  - `requests`
  - `beautifulsoup4`
  - `colorama`

You can install the required libraries using `pip`:

```bash
pip install requests beautifulsoup4 colorama
