import AppKit

/// Spotlight-style input bar. Non-activating, so the app you were in stays frontmost.
final class CapturePanel: NSPanel, NSTextFieldDelegate {
    private let field = NSTextField()
    private let onSubmit: (String) -> Bool

    /// `onSubmit` returns false if saving failed; the text is then kept.
    init(onSubmit: @escaping (String) -> Bool) {
        self.onSubmit = onSubmit
        super.init(contentRect: NSRect(x: 0, y: 0, width: 640, height: 60),
                   styleMask: [.nonactivatingPanel, .borderless, .fullSizeContentView],
                   backing: .buffered, defer: false)
        isFloatingPanel = true
        level = .modalPanel
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        hidesOnDeactivate = false
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        let background = NSVisualEffectView()
        background.material = .popover
        background.blendingMode = .behindWindow
        background.state = .active
        background.maskImage = Self.roundedMask(radius: 14)
        contentView = background

        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.font = .systemFont(ofSize: 22)
        field.placeholderString = "Capture a thought"
        field.usesSingleLineMode = true
        field.cell?.isScrollable = true
        field.cell?.wraps = false
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(field)
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 20),
            field.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -20),
            field.centerYAnchor.constraint(equalTo: background.centerYAnchor),
        ])
    }

    override var canBecomeKey: Bool { true }

    /// Clicking elsewhere hides the bar but keeps the draft for next time.
    override func resignKey() {
        super.resignKey()
        orderOut(nil)
    }

    func toggle() {
        isVisible ? orderOut(nil) : present()
    }

    func present() {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main!
        let area = screen.visibleFrame
        setFrameOrigin(NSPoint(x: area.midX - frame.width / 2,
                               y: area.minY + area.height * 0.72 - frame.height / 2))
        makeKeyAndOrderFront(nil)
        makeFirstResponder(field)
        field.currentEditor()?.selectedRange = NSRange(location: field.stringValue.utf16.count, length: 0)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
        switch selector {
        case #selector(NSResponder.insertNewline(_:)):
            let text = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                guard onSubmit(text) else { NSSound.beep(); return true }
            }
            field.stringValue = ""
            orderOut(nil)
        case #selector(NSResponder.cancelOperation(_:)):
            field.stringValue = ""
            orderOut(nil)
        default:
            return false
        }
        return true
    }

    private static func roundedMask(radius: CGFloat) -> NSImage {
        let size = NSSize(width: radius * 2 + 1, height: radius * 2 + 1)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setFill()
            NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
            return true
        }
        image.capInsets = NSEdgeInsets(top: radius, left: radius, bottom: radius, right: radius)
        image.resizingMode = .stretch
        return image
    }
}
