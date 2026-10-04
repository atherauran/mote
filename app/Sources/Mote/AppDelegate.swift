import AppKit
import Carbon
import ServiceManagement
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private let hosting = NSHostingController(rootView: NotesView(days: [], onNewNote: {}))
    private var panel: CapturePanel!
    private var hotKey: HotKey?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = Self.editMenu()

        // Open at Login defaults to on; after the first launch it's left to the menu toggle.
        if !UserDefaults.standard.bool(forKey: "loginItemConfigured") {
            try? SMAppService.mainApp.register()
            UserDefaults.standard.set(true, forKey: "loginItemConfigured")
        }

        panel = CapturePanel { text in
            do {
                try NoteStore.append(text)
                return true
            } catch {
                NSLog("Mote: failed to save note: \(error)")
                return false
            }
        }

        hotKey = HotKey(keyCode: kVK_Space, modifiers: optionKey) { [weak self] in
            self?.panel.toggle()
        }

        hosting.sizingOptions = []
        popover.contentViewController = hosting
        popover.contentSize = NSSize(width: 380, height: 480)
        popover.behavior = .transient

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "smallcircle.filled.circle", accessibilityDescription: "Mote")
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
    }

    /// Never shown (no Dock/menu bar presence), but it's what makes ⌘X/C/V/A/Z work in text fields.
    private static func editMenu() -> NSMenu {
        let edit = NSMenu(title: "Edit")
        edit.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        edit.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        edit.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        edit.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        let item = NSMenuItem()
        item.submenu = edit
        let main = NSMenu()
        main.addItem(item)
        return main
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
            return
        }
        hosting.rootView = NotesView(days: NoteStore.loadDays()) { [weak self] in
            self?.popover.performClose(nil)
            self?.panel.present()
        }
        NSApp.activate()
        let button = statusItem.button!
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
}
