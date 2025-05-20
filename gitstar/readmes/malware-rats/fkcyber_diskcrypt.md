# diskcrypt

Recursive disk encryptor for Windows, Linux, MacOS

## Installation

Firstly, clone the repository or download the latest release:

```
git clone https://github.com/fkcyber/diskcrypt
```

Then install the requirements using PIP:

```
pip install -r requirements.txt
```

## Usage

Run in quiet mode:

```
python3 main.py -q -p password123 -s salt123
```

Run without quiet mode:

```
python3 main.py -p password123 -s salt123
```