#!/usr/bin/env swift
import AppKit

let args = CommandLine.arguments
guard args.count >= 3 else { exit(1) }
let word = args[1]
let translation = args[2]

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

// Get mouse location
let mouseLoc = NSEvent.mouseLocation

// Create panel (floating, no focus steal)
let panel = NSPanel(
    contentRect: NSRect(x: 0, y: 0, width: 240, height: 64),
    styleMask: [.borderless, .nonactivatingPanel],
    backing: .buffered,
    defer: true
)
panel.level = NSWindow.Level.floating
panel.isOpaque = false
panel.backgroundColor = NSColor.clear
panel.hidesOnDeactivate = false

// Background - solid dark
let bgView = NSView(frame: panel.contentView!.bounds)
bgView.wantsLayer = true
bgView.layer?.backgroundColor = NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 0.95).cgColor
bgView.layer?.cornerRadius = 10

// Label
let label = NSTextField(wrappingLabelWithString: "\(word)\n\(translation)")
label.font = NSFont(name: "PingFang SC", size: 16)
label.textColor = NSColor.white
label.alignment = .center
label.backgroundColor = NSColor.clear
label.isBezeled = false
label.isEditable = false
label.frame = NSRect(x: 8, y: 4, width: 224, height: 56)

bgView.addSubview(label)
panel.contentView?.addSubview(bgView)

// Position near mouse
let x = mouseLoc.x - 120
let y = mouseLoc.y + 12
panel.setFrameOrigin(NSPoint(x: x, y: y))
panel.orderFrontRegardless()

// Auto close after 3 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    NSApp.terminate(nil)
}

app.run()
