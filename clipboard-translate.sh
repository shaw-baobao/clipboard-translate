#!/bin/bash
# clipboard-translate: monitors clipboard, shows Chinese translation popup
# Usage: run in background, then just ⌘C any word to see translation

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POPUP="$SCRIPT_DIR/translate-popup"

# Fallback: check common install locations
if [[ ! -x "$POPUP" ]]; then
    POPUP="$HOME/.local/bin/translate-popup"
fi

# Find translate-shell
TRANS=$(command -v trans 2>/dev/null)
if [[ -z "$TRANS" || ! -x "$TRANS" ]]; then
    echo "Error: translate-shell not found. Install with: brew install translate-shell" >&2
    exit 1
fi

# Cache for translated words
CACHE_DIR="$HOME/.cache/clipboard-translate"
mkdir -p "$CACHE_DIR"

LAST=""

while true; do
    CURRENT=$(pbpaste 2>/dev/null)

    if [[ "$CURRENT" != "$LAST" && -n "$CURRENT" && ${#CURRENT} -le 100 && "$CURRENT" != *$'\n'* ]]; then
        LAST="$CURRENT"
        WORD="${CURRENT#"${CURRENT%%[![:space:]]*}"}"
        WORD="${WORD%"${WORD##*[![:space:]]}"}"
        # Skip non-ASCII text, URLs, file paths
        if [[ -n "$WORD" && "$WORD" != http* && "$WORD" != /* ]] && printf '%s' "$WORD" | LC_ALL=C /usr/bin/grep -qE "^[a-zA-Z0-9 _.,'\":;!?()+-]+$"; then
            LOWER=$(printf '%s' "$WORD" | tr '[:upper:]' '[:lower:]')
            CACHE_FILE="$CACHE_DIR/$LOWER"
            # Check cache first
            if [[ -f "$CACHE_FILE" ]]; then
                RESULT=$(cat "$CACHE_FILE")
            else
                RESULT=$("$TRANS" -b :zh "$WORD" 2>/dev/null)
                # Save to cache
                if [[ -n "$RESULT" ]]; then
                    printf '%s' "$RESULT" > "$CACHE_FILE"
                fi
            fi
            if [[ -n "$RESULT" ]]; then
                "$POPUP" "$WORD" "$RESULT" &
            fi
        fi
    fi

    sleep 0.5
done
