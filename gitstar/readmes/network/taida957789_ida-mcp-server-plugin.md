# IDA Pro MCP Server

IDA Pro MCP Server is a plugin that allows remote querying and control of IDA Pro through the Model Context Protocol (MCP) interface. This plugin enables AI assistants (such as Claude) to interact directly with IDA Pro for binary analysis tasks.

## Overview

This server provides a series of tools that allow AI assistants to perform the following operations:
- Get byte data from specific addresses
- Get disassembly code
- Get decompiled pseudocode
- Query function names
- Get segment information
- List all functions
- Find cross-references
- Get import/export tables
- Get entry points
- Define/undefine functions
- Get various data types (dword, word, byte, qword, float, double, string)
- Get all strings in the binary file
- Get the length of the instruction at the specified address

## Installation

> **Note:** This plugin is designed for and tested with IDA Pro version 9.0+.

1. Ensure Python and related dependencies are installed:

```bash
pip install -r requirements.txt
```

2. Copy the `ida-mcp-server.py` file to the IDA Pro plugins directory:
   - Windows: `%Programfiles%\IDA Pro 9.0\plugins\`
   - Linux: `~/.idapro/plugins/`
   - macOS: `~/Library/Application Support/IDA Pro/plugins/`

## Configure Claude / VSCode

Add the following configuration to the `mcp.json` file in Claude or VSCode:

```json
{
  "mcpServers": {
    "IDAPro": {
      "url": "http://127.0.0.1:3000/sse",
      "type": "sse"
    }
  }
}
```

## Usage

1. Open a binary file in IDA Pro
2. The plugin will automatically load and start the MCP server locally (port 3000)
3. Connect your AI assistant (e.g., Claude) to this server
4. Use the AI assistant to perform binary analysis tasks

## Available Analysis Tools

IDA Pro MCP Server provides the following tools:

- `get_bytes`: Get bytes at a specified address
- `get_disasm`: Get disassembly at a specified address
- `get_decompiled_func`: Get pseudocode of the function containing the specified address
- `get_function_name`: Get function name at a specified address
- `get_segments`: Get all segment information
- `get_functions`: Get all functions in the binary
- `get_xrefs_to`: Get all cross-references to a specified address
- `get_imports`: Get all imported functions
- `get_exports`: Get all exported functions
- `get_entry_point`: Get the entry point of the binary
- `make_function`: Create a function at a specified address
- `undefine_function`: Undefine a function at a specified address
- `get_dword_at`: Get the dword at a specified address
- `get_word_at`: Get the word at a specified address
- `get_byte_at`: Get the byte at a specified address
- `get_qword_at`: Get the qword at a specified address
- `get_float_at`: Get the float at a specified address
- `get_double_at`: Get the double at a specified address
- `get_string_at`: Get the string at a specified address
- `get_string_list`: Get all strings in the binary
- `get_strings`: Get all strings in the binary (with addresses)

## Best Practices

When analyzing binary files, it's recommended to follow these steps:

1. Examine the entry point
2. Analyze the import table
3. Review strings
4. Track key API calls
5. Identify main functional blocks
6. Analyze control flow
7. Identify malicious behaviors
8. Analyze algorithms and encryption routines
9. Document analysis results
10. Use advanced techniques

## License

MIT License

Copyright (c) 2023 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
