# clipboard-translate

[English](#english) | [中文](#中文)

---

<a id="english"></a>

Select a word, press `⌘C`, see the Chinese translation in a floating popup. No buttons, no focus stealing, auto-dismisses in 3 seconds.

Works in any macOS app — including GPU-rendered terminals like Warp.

## Demo

1. Double-click a word to select it
2. Press `⌘C`
3. A dark popup appears near your cursor with the translation
4. It disappears after 3 seconds

## Requirements

- macOS
- [translate-shell](https://github.com/soimort/translate-shell)

## Install

```bash
brew install translate-shell
git clone https://github.com/shaw-baobao/clipboard-translate.git
cd clipboard-translate
make install
```

## Usage

```bash
# Start the clipboard watcher
make start

# Stop it
make stop
```

## Auto-start on login

```bash
cp com.clipboard-translate.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.clipboard-translate.plist
```

## Uninstall

```bash
make uninstall
```

## How it works

Two components:

1. **clipboard-translate.sh** — A bash loop that polls the clipboard every 0.5s. When it detects new short text (from `⌘C`), it calls `translate-shell` to get the Chinese translation.

2. **translate-popup** (Swift) — A native macOS `NSPanel` with `nonactivatingPanel` style that floats above all windows without stealing focus. Shows the word + translation, auto-closes after 3 seconds.

## License

Apache 2.0

---

<a id="中文"></a>

## 中文说明

选中一个单词，按 `⌘C`，鼠标旁边会弹出一个浮动窗口显示中文翻译。无按钮、不抢焦点、3 秒后自动消失。

适用于所有 macOS 应用，包括 Warp 等 GPU 渲染的终端。

### 演示

1. 双击选中一个单词
2. 按 `⌘C`
3. 鼠标旁边出现一个深色弹窗，显示翻译结果
4. 3 秒后自动消失

### 依赖

- macOS
- [translate-shell](https://github.com/soimort/translate-shell)

### 安装

```bash
brew install translate-shell
git clone https://github.com/shaw-baobao/clipboard-translate.git
cd clipboard-translate
make install
```

### 使用

```bash
# 启动剪贴板监听
make start

# 停止
make stop
```

### 开机自启

```bash
cp com.clipboard-translate.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.clipboard-translate.plist
```

### 卸载

```bash
make uninstall
```

### 工作原理

两个组件：

1. **clipboard-translate.sh** — 一个 bash 循环，每 0.5 秒检查剪贴板。当检测到新的短文本（来自 `⌘C`），调用 `translate-shell` 获取中文翻译。

2. **translate-popup**（Swift）— 一个原生 macOS `NSPanel`，使用 `nonactivatingPanel` 样式，悬浮在所有窗口之上且不抢焦点。显示单词 + 翻译，3 秒后自动关闭。

### 许可证

Apache 2.0
