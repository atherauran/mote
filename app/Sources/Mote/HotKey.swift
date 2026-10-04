import Carbon

/// A system-wide hotkey via Carbon's RegisterEventHotKey (needs no Accessibility permission).
final class HotKey {
    private var ref: EventHotKeyRef?
    private let action: () -> Void

    init(keyCode: Int, modifiers: Int, action: @escaping () -> Void) {
        self.action = action

        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, userData in
            Unmanaged<HotKey>.fromOpaque(userData!).takeUnretainedValue().action()
            return noErr
        }, 1, &spec, Unmanaged.passUnretained(self).toOpaque(), nil)

        let status = RegisterEventHotKey(UInt32(keyCode), UInt32(modifiers),
                                         EventHotKeyID(signature: OSType(0x4D4F5445), id: 1),
                                         GetApplicationEventTarget(), 0, &ref)
        if status != noErr {
            NSLog("Mote: could not register hotkey (OSStatus \(status)); another app may own it")
        }
    }
}
