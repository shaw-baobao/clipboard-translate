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

# Translate function: use Google Translate API directly via curl (faster than translate-shell)
translate() {
    local encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))" 2>/dev/null || printf '%s' "$1" | sed 's/ /+/g')
    local json=$(curl -s --max-time 5 "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=zh&dt=t&q=$encoded" -H "User-Agent: Mozilla/5.0")
    printf '%s' "$json" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(''.join(s[0] for s in d[0]))" 2>/dev/null
}

# Cache for translated words
CACHE_DIR="$HOME/.cache/clipboard-translate"
mkdir -p "$CACHE_DIR"

LAST=""

while true; do
    CURRENT=$(pbpaste 2>/dev/null)

    if [[ "$CURRENT" != "$LAST" && -n "$CURRENT" && ${#CURRENT} -le 500 && "$CURRENT" != *$'\n'* ]]; then
        LAST="$CURRENT"
        WORD="${CURRENT#"${CURRENT%%[![:space:]]*}"}"
        WORD="${WORD%"${WORD##*[![:space:]]}"}"
        # Skip URLs, file paths, and CJK text; must contain English letters
        if [[ -n "$WORD" && "$WORD" != http* && "$WORD" != /* ]] \
            && printf '%s' "$WORD" | /usr/bin/grep -q '[a-zA-Z]' \
            && /usr/bin/perl -e 'use Encode; my $s = decode("UTF-8", $ARGV[0]); exit 1 if $s =~ /[\x{4e00}-\x{9fff}\x{3400}-\x{4dbf}\x{3040}-\x{30ff}\x{ac00}-\x{d7af}]/; exit 0;' "$WORD" 2>/dev/null; then
            LOWER=$(printf '%s' "$WORD" | tr '[:upper:]' '[:lower:]')
            CACHE_FILE="$CACHE_DIR/$LOWER"
            # Check cache first
            if [[ -f "$CACHE_FILE" ]]; then
                RESULT=$(cat "$CACHE_FILE")
            else
                RESULT=$(translate "$WORD")
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

    sleep 0.2
done
