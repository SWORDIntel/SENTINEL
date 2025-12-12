import argparse
import os
import re
import sys
from pathlib import Path

import yaml


_SAFE_ENV_RE = re.compile(r"^[A-Z_][A-Z0-9_]*$")


def _shell_single_quote(value: str) -> str:
    """
    Return a single-quoted shell string, safely escaping single quotes.
    e.g. abc'd -> 'abc'"'"'d'
    """
    return "'" + value.replace("'", "'\"'\"'") + "'"


def _safe_env_name(name: str) -> str | None:
    # Uppercase and replace unsafe characters with underscores
    n = re.sub(r"[^A-Z0-9_]", "_", name.upper())
    if not _SAFE_ENV_RE.match(n):
        return None
    return n

def parse_yaml(file_path: Path):
    with file_path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def _iter_kv(settings, prefix: str | None = None):
    """
    Iterate key/value pairs. For nested dicts, flatten using PREFIX_KEY naming.
    """
    if isinstance(settings, dict):
        for k, v in settings.items():
            k_str = str(k)
            if prefix:
                yield from _iter_kv(v, f"{prefix}_{k_str}")
            else:
                yield from _iter_kv(v, k_str)
    else:
        # Leaf
        yield (prefix, settings)

def export_variables(config) -> list[str]:
    """
    Generate safe `export KEY='VALUE'` lines.

    Backwards compatibility:
    - For standard top-level sections with leaf keys, export by leaf key only
      (matches the historical behavior).
    - For nested dicts, export using flattened names (e.g. FABRIC_TELEMETRY_ENABLED).
    """
    lines: list[str] = []

    def emit(var_name: str, value) -> None:
        safe_name = _safe_env_name(var_name)
        if not safe_name:
            # Refuse to emit unsafe env var names (prevents injection via config keys)
            return

        if value is None:
            value_str = ""
        elif isinstance(value, bool):
            value_str = "1" if value else "0"
        elif isinstance(value, (int, float)):
            value_str = str(value)
        elif isinstance(value, (list, tuple)):
            value_str = " ".join(str(x) for x in value)
        else:
            value_str = str(value)

        # Replace ~ with $HOME for shell compatibility
        value_str = value_str.replace("~", "$HOME")
        lines.append(f"export {safe_name}={_shell_single_quote(value_str)}")

    for _section, settings in (config or {}).items():
        if not isinstance(settings, dict):
            continue

        for key, value in settings.items():
            # Special cases used by the module system
            if key == "enabled_modules":
                emit("SENTINEL_MODULES_ENABLED", value)
                continue
            if key == "lazy_load_modules":
                emit("SENTINEL_LAZY_LOAD_MODULES", value)
                continue
            if key == "core_modules":
                emit("SENTINEL_CORE_MODULES", value)
                continue

            # Historical behavior: export by leaf key only. For nested structures,
            # flatten with KEY_SUBKEY... naming.
            if isinstance(value, dict):
                for flat_key, flat_val in _iter_kv(value, prefix=str(key)):
                    if flat_key:
                        emit(flat_key, flat_val)
            else:
                emit(str(key), value)

    return lines

def _default_root() -> Path:
    env_root = os.environ.get("SENTINEL_ROOT", "")
    if env_root:
        p = Path(env_root).expanduser()
        if p.exists():
            return p
    # /installer/config.py -> project root is parent of installer/
    return Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--config", default=None)
    parser.add_argument("--output", default=None)
    args, _unknown = parser.parse_known_args()

    root = _default_root()
    config_path = Path(args.config).expanduser() if args.config else (root / "config.yaml")
    dist_path = root / "config.yaml.dist"

    if config_path.exists():
        config = parse_yaml(config_path)
    elif dist_path.exists():
        config = parse_yaml(dist_path)
    else:
        print("echo 'Configuration file not found.' >&2")
        return 1

    lines = export_variables(config)
    content = "\n".join(lines) + ("\n" if lines else "")

    if args.output:
        out_path = Path(args.output).expanduser()
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(content, encoding="utf-8")
        return 0

    sys.stdout.write(content)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
