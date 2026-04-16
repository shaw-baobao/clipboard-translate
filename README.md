# clipboard-translate

[English](README.md) | [中文](README_CN.md)

Select a word, press `⌘C`, see the Chinese translation in a floating popup. No buttons, no focus stealing, auto-dismisses in 3 seconds.

Works in any macOS app — including GPU-rendered terminals like Warp.

## Demo

1. Double-click a word to select it
2. Press `⌘C`
3. A dark popup appears near your cursor with the translation
4. It disappears after 3 seconds

## Quick Install

```bash
curl -sL https://raw.githubusercontent.com/shaw-baobao/clipboard-translate/main/install.sh | bash
```

This will download the pre-built binary, install dependencies, and set up auto-start on login.

## Manual Install

```bash
brew install translate-shell
git clone https://github.com/shaw-baobao/clipboard-translate.git
cd clipboard-translate
make install
make start
```

## Uninstall

```bash
curl -sL https://raw.githubusercontent.com/shaw-baobao/clipboard-translate/main/uninstall.sh | bash
```

## How it works

Two components:

1. **clipboard-translate.sh** — A bash loop that polls the clipboard every 0.5s. When it detects new short text (from `⌘C`), it calls `translate-shell` to get the Chinese translation.

2. **translate-popup** (Swift) — A native macOS `NSPanel` with `nonactivatingPanel` style that floats above all windows without stealing focus. Shows the word + translation, auto-closes after 3 seconds.

## License

Apache 2.0
