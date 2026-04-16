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

// Calculate size based on content
let displayText = "\(word)\n\(translation)"
let font = NSFont(name: "PingFang SC", size: 16) ?? NSFont.systemFont(ofSize: 16)
let maxWidth: CGFloat = 400
let padding: CGFloat = 24

let textAttr: [NSAttributedString.Key: Any] = [
    .font: font,
    .paragraphStyle: {
        let p = NSMutableParagraphStyle()
        p.alignment = .center
        return p
    }()
]
let textSize = (displayText as NSString).boundingRect(
    with: NSSize(width: maxWidth - padding * 2, height: 800),
    options: [.usesLineFragmentOrigin, .usesFontLeading],
    attributes: textAttr
)

let w = min(max(textSize.width + padding * 2, 120), maxWidth)
let h = textSize.height + padding

// Create panel (floating, no focus steal)
let panel = NSPanel(
    contentRect: NSRect(x: 0, y: 0, width: w, height: h),
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
let label = NSTextField(wrappingLabelWithString: displayText)
label.font = font
label.textColor = NSColor.white
label.alignment = .center
label.backgroundColor = NSColor.clear
label.isBezeled = false
label.isEditable = false
label.frame = NSRect(x: padding / 2, y: padding / 4, width: w - padding, height: h - padding / 2)

bgView.addSubview(label)
panel.contentView?.addSubview(bgView)

// Position near mouse
let x = mouseLoc.x - w / 2
let y = mouseLoc.y + 12
panel.setFrameOrigin(NSPoint(x: x, y: y))
panel.orderFrontRegardless()

// Auto close: ~1s per 10 chars, min 3s, max 10s
let charCount = Double(displayText.count)
let duration = min(max(charCount / 10.0, 3.0), 10.0)
DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
    NSApp.terminate(nil)
}

app.run()
