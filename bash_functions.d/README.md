# SENTINEL Path Manager

SENTINEL Path Manager provides a robust solution for managing custom PATH entries with persistent storage between shell sessions.

## Features

- Persistent path management (survives across shell restarts)
- Validation of path entries
- Interactive management (add, remove, list)
- Automatic loading of saved paths
- Compatibility with the original `add2path` function

## Commands

- `add_path [directory]` - Add a directory to PATH and save it to configuration
- `remove_path [directory]` - Remove a directory from the persistent configuration
- `list_paths` - Show all saved path entries
- `refresh_paths` - Reload all paths from configuration

## Usage Examples

```bash
# Add the current directory to PATH
add_path

# Add a specific directory to PATH
add_path ~/bin

# List all configured paths
list_paths

# Remove a path interactively
remove_path

# Remove a specific path
remove_path ~/bin

# Refresh paths from configuration
refresh_paths
```

## Configuration File

All paths are stored in `~/.sentinel_paths`, which is a simple text file with one path per line.
Lines beginning with # are treated as comments.

## Security Features

- Only adds directories that exist to PATH
- Full path resolution before adding
- Duplication prevention

## Compatibility

The original `add2path` function is preserved for backward compatibility and now redirects to the new system. 