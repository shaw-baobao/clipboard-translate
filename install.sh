#!/bin/bash
set -e

REPO="shaw-baobao/clipboard-translate"
INSTALL_DIR="$HOME/.local/bin"

ASSET="clipboard-translate-macos-universal.tar.gz"

echo "Installing clipboard-translate..."

# Check dependencies
if ! command -v trans &>/dev/null; then
    echo "Installing translate-shell..."
    if command -v brew &>/dev/null; then
        brew install translate-shell
    else
        echo "Error: translate-shell is required. Install Homebrew first, then run: brew install translate-shell"
        exit 1
    fi
fi

# Download latest release
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
    | grep "browser_download_url.*$ASSET" \
    | cut -d '"' -f 4)

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "Error: could not find release for $ASSET"
    echo "Building from source instead..."
    TMPDIR=$(mktemp -d)
    git clone "https://github.com/$REPO.git" "$TMPDIR/clipboard-translate"
    cd "$TMPDIR/clipboard-translate"
    swiftc translate-popup.swift -o translate-popup -O
    mkdir -p "$INSTALL_DIR"
    cp translate-popup "$INSTALL_DIR/"
    cp clipboard-translate.sh "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/clipboard-translate.sh"
    rm -rf "$TMPDIR"
else
    TMPDIR=$(mktemp -d)
    echo "Downloading $ASSET..."
    curl -sL "$DOWNLOAD_URL" -o "$TMPDIR/$ASSET"
    tar xzf "$TMPDIR/$ASSET" -C "$TMPDIR"
    mkdir -p "$INSTALL_DIR"
    cp "$TMPDIR/translate-popup" "$INSTALL_DIR/"
    cp "$TMPDIR/clipboard-translate.sh" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/clipboard-translate.sh"
    rm -rf "$TMPDIR"
fi

# Set up LaunchAgent for auto-start
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST="$PLIST_DIR/com.clipboard-translate.plist"
mkdir -p "$PLIST_DIR"

cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.clipboard-translate</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${INSTALL_DIR}/clipboard-translate.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# Start the service
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo ""
echo "✅ clipboard-translate installed!"
echo ""
echo "Usage: select a word → ⌘C → see translation popup"
echo ""
echo "Commands:"
echo "  Stop:      launchctl unload ~/Library/LaunchAgents/com.clipboard-translate.plist"
echo "  Start:     launchctl load ~/Library/LaunchAgents/com.clipboard-translate.plist"
echo "  Uninstall: curl -sL https://raw.githubusercontent.com/$REPO/main/uninstall.sh | bash"
