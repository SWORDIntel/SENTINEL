# Kitty GPU-Accelerated Terminal Integration (Optional)

SENTINEL can optionally integrate with the [kitty](https://sw.kovidgoyal.net/kitty/) terminal to improve TUI responsiveness via GPU-accelerated rendering.

This integration is **optional** and is **never required**. It is designed to **gracefully fall back** on headless/SSH/no-GUI systems.

## Requirements

- `kitty` is installed and available in `PATH`
- A GUI session is available: `DISPLAY` or `WAYLAND_DISPLAY` is set

## Installer behavior

During installation you’ll be asked:

> Enable Kitty GPU-accelerated terminal integration? (optional)

If you answer **Yes**:
- If kitty + GUI are detected, the installer:
  - Writes a conservative, low-latency Kitty config block to:
    - `${XDG_CONFIG_HOME:-~/.config}/kitty/kitty.conf`
  - Installs a launcher:
    - `~/.local/bin/sentinel-tty`
- If kitty + GUI are **not** detected, the installer prints a warning and continues **without enabling** kitty mode.

If you answer **No**:
- No changes are made.

## How fallback works (`sentinel-tty`)

`sentinel-tty` chooses the best available path:

- If already inside kitty (`KITTY_WINDOW_ID` set): run the SENTINEL entrypoint normally.
- Else if kitty is available and GUI is available: run the entrypoint inside kitty (`kitty -e bash -lc ...`).
- Else (headless/SSH/no GUI): run in the current terminal.

## How to disable

- Remove the SENTINEL block from `kitty.conf` (between `# SENTINEL KITTY BEGIN` and `# SENTINEL KITTY END`)
- Remove the launcher: `~/.local/bin/sentinel-tty`
- Re-run the installer and choose “No” when prompted

## Common issues

- **Nothing happens / no GUI detected**: ensure `DISPLAY` or `WAYLAND_DISPLAY` is set in your session.
- **kitty not found**: install kitty and ensure it’s on `PATH`.
- **Remote SSH session**: kitty spawning typically won’t work unless you have X11/Wayland forwarding; fallback will run in the current terminal.

