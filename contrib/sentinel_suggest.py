#!/usr/bin/env python3
# sentinel_suggest.py: ML-powered CLI suggestions
# Requires: pip install markovify

# Standard library imports
import os
import sys

# Third-party imports (with robust error handling)
try:
    import markovify
except ImportError as e:
    print(f"Missing dependency: {e}")
    print("Install with: pip install markovify")
    sys.exit(1)

# Config files
HISTORY_FILE = os.path.expanduser("~/logs/command_history")
MODEL_FILE = os.path.expanduser("~/models/command_model.json")

# Attempt to load existing model
model = None
if os.path.exists(MODEL_FILE):
    try:
        model_json = open(MODEL_FILE).read()
        model = markovify.NewlineText.from_json(model_json)
    except Exception:
        model = None

# Build model from history if not loaded
if model is None and os.path.exists(HISTORY_FILE):
    text = open(HISTORY_FILE).read()
    if text.strip():
        model = markovify.NewlineText(text, state_size=2)
        with open(MODEL_FILE, 'w') as f:
            f.write(model.to_json())

# Generate suggestions based on current prefix


def suggest(prefix, n=5):
    suggestions = []
    if model:
        for _ in range(n * 2):
            sentence = model.make_sentence_with_start(prefix, strict=False)
            if sentence and sentence not in suggestions:
                suggestions.append(sentence)
            if len(suggestions) >= n:
                break
    return suggestions


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(0)
    prefix = sys.argv[1]
    for s in suggest(prefix):
        print(s)
