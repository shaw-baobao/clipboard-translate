#!/bin/bash
set -e

INSTALL_DIR="$HOME/.local/bin"
PLIST="$HOME/Library/LaunchAgents/com.clipboard-translate.plist"

echo "Uninstalling clipboard-translate..."

# Stop service
launchctl unload "$PLIST" 2>/dev/null || true
pkill -f clipboard-translate.sh 2>/dev/null || true

# Remove files
rm -f "$INSTALL_DIR/translate-popup"
rm -f "$INSTALL_DIR/clipboard-translate.sh"
rm -f "$PLIST"

echo "✅ clipboard-translate uninstalled!"
