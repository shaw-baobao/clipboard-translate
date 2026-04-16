PREFIX ?= $(HOME)/.local

.PHONY: build install uninstall start stop

build:
	swiftc translate-popup.swift -o translate-popup

install: build
	mkdir -p $(PREFIX)/bin
	cp translate-popup $(PREFIX)/bin/translate-popup
	cp clipboard-translate.sh $(PREFIX)/bin/clipboard-translate.sh
	chmod +x $(PREFIX)/bin/clipboard-translate.sh
	@echo "Installed to $(PREFIX)/bin"
	@echo "Run 'make start' to start the clipboard watcher"

uninstall: stop
	rm -f $(PREFIX)/bin/translate-popup
	rm -f $(PREFIX)/bin/clipboard-translate.sh
	rm -f ~/Library/LaunchAgents/com.clipboard-translate.plist
	@echo "Uninstalled"

start:
	@nohup $(PREFIX)/bin/clipboard-translate.sh > /dev/null 2>&1 &
	@echo "Started (PID: $$!)"

stop:
	@pkill -f clipboard-translate.sh 2>/dev/null || true
	@echo "Stopped"
