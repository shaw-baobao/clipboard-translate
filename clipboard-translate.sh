#!/bin/bash
# clipboard-translate: monitors clipboard, shows Chinese translation popup
# Usage: run in background, then just ⌘C any word to see translation

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POPUP="$SCRIPT_DIR/translate-popup"

# Fallback: check common install locations
if [[ ! -x "$POPUP" ]]; then
    POPUP="$HOME/.local/bin/translate-popup"
fi

# Find translate-shell
TRANS=$(command -v trans 2>/dev/null || echo "/opt/homebrew/bin/trans")
if [[ ! -x "$TRANS" ]]; then
    echo "Error: translate-shell not found. Install with: brew install translate-shell" >&2
    exit 1
fi

LAST=""

while true; do
    CURRENT=$(pbpaste 2>/dev/null)

    if [[ "$CURRENT" != "$LAST" && -n "$CURRENT" && ${#CURRENT} -le 100 && "$CURRENT" != *$'\n'* ]]; then
        LAST="$CURRENT"
        WORD=$(echo "$CURRENT" | xargs)
        if [[ -n "$WORD" ]]; then
            RESULT=$("$TRANS" -b :zh "$WORD" 2>/dev/null)
            if [[ -n "$RESULT" ]]; then
                "$POPUP" "$WORD" "$RESULT" &
            fi
        fi
    fi

    sleep 0.5
done
