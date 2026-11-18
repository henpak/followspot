import AppKit
import Carbon.HIToolbox

enum HotkeyAction: UInt32, CaseIterable {
    case highlight = 1
    case spotlight = 2
    case halo = 3
    // 4 was Esc (removed); not reused so IDs stay stable.
    case clickRings = 5

    /// Shortcuts that are registered at launch.
    static let standard: [HotkeyAction] = [.highlight, .spotlight, .halo, .clickRings]

    // Option + F1–F4: one modifier, reachable with one hand, types no character and is
    // not a macOS system shortcut (design.md of use-function-key-hotkeys, Decisions 1–3).
    var keyCode: UInt32 {
        switch self {
        case .highlight: return UInt32(kVK_F1)
        case .spotlight: return UInt32(kVK_F2)
        case .halo: return UInt32(kVK_F3)
        case .clickRings: return UInt32(kVK_F4)
        }
    }

    var carbonModifiers: UInt32 {
        UInt32(optionKey)
    }

    /// Modifier mask for the menu's key equivalent; must match `carbonModifiers`.
    var menuModifiers: NSEvent.ModifierFlags {
        [.option]
    }

    /// Key equivalent for displaying the shortcut in the menu.
    var menuKey: String {
        switch self {
        case .highlight: return Self.functionKey(NSF1FunctionKey)
        case .spotlight: return Self.functionKey(NSF2FunctionKey)
        case .halo: return Self.functionKey(NSF3FunctionKey)
        case .clickRings: return Self.functionKey(NSF4FunctionKey)
        }
    }

    var displayShortcut: String {
        switch self {
        case .highlight: return "⌥F1"
        case .spotlight: return "⌥F2"
        case .halo: return "⌥F3"
        case .clickRings: return "⌥F4"
        }
    }

    private static func functionKey(_ code: Int) -> String {
        String(Character(UnicodeScalar(UInt16(code))!))
    }
}

/// System-wide hotkeys via Carbon `RegisterEventHotKey` – needs no special permissions,
/// and the shortcut is consumed (does not reach the frontmost app). design.md, Decision 6.
@MainActor
final class HotkeyManager {
    var onHotkey: ((HotkeyAction) -> Void)?

    /// Standard shortcuts that could not be registered.
    private(set) var failedActions: [HotkeyAction] = []

    private var refs: [HotkeyAction: EventHotKeyRef] = [:]
    private var handlerRef: EventHandlerRef?
    private static let signature: OSType = 0x464C_5350 // 'FLSP'

    func start() {
        installHandler()
        failedActions = HotkeyAction.standard.filter { !register($0) }
        for action in failedActions {
            Log.event("hotkey \(action.displayShortcut) could NOT be registered")
        }
    }

    func stop() {
        for action in Array(refs.keys) { unregister(action) }
        if let handlerRef {
            RemoveEventHandler(handlerRef)
            self.handlerRef = nil
        }
    }

    // MARK: Carbon

    private func installHandler() {
        guard handlerRef == nil else { return }
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let userData = Unmanaged.passUnretained(self).toOpaque()
        let status = InstallEventHandler(GetApplicationEventTarget(), { _, event, userData in
            guard let event, let userData else { return OSStatus(eventNotHandledErr) }
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(event,
                                           EventParamName(kEventParamDirectObject),
                                           EventParamType(typeEventHotKeyID),
                                           nil,
                                           MemoryLayout<EventHotKeyID>.size,
                                           nil,
                                           &hotKeyID)
            guard status == noErr,
                  hotKeyID.signature == HotkeyManager.signature,
                  let action = HotkeyAction(rawValue: hotKeyID.id) else {
                return OSStatus(eventNotHandledErr)
            }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            // Carbon delivers hotkey events on the main thread.
            MainActor.assumeIsolated {
                Log.event("hotkey \(action.displayShortcut)")
                manager.onHotkey?(action)
            }
            return noErr
        }, 1, &spec, userData, &handlerRef)
        if status != noErr {
            Log.event("hotkey handler could NOT be installed (\(status))")
        }
    }

    private func register(_ action: HotkeyAction) -> Bool {
        var ref: EventHotKeyRef?
        let id = EventHotKeyID(signature: Self.signature, id: action.rawValue)
        let status = RegisterEventHotKey(action.keyCode, action.carbonModifiers, id,
                                         GetApplicationEventTarget(), 0, &ref)
        guard status == noErr, let ref else { return false }
        refs[action] = ref
        return true
    }

    private func unregister(_ action: HotkeyAction) {
        if let ref = refs.removeValue(forKey: action) {
            UnregisterEventHotKey(ref)
        }
    }
}
