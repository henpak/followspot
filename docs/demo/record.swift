// Records the README screenshots and clips of Followspot on a neutral demo page.
//
// Usage: compiled and run by scripts/record-demo.sh (needs Screen Recording and
// Accessibility permission for the terminal). Writes *.mov and *.png into the
// output directory given as the first argument.
import AppKit
import WebKit

let outputDir = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ".")
let pageURL = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("index.html")
let contentSize = CGSize(width: 1200, height: 590)

// MARK: - Input

enum Key: CGKeyCode {
    case f1 = 122, f2 = 120, f3 = 99, f4 = 118, escape = 53
}

let source = CGEventSource(stateID: .hidSystemState)

func post(_ event: CGEvent?) {
    event?.post(tap: .cghidEventTap)
}

func keyEvent(_ code: CGKeyCode, down: Bool, flags: CGEventFlags) {
    let event = CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: down)
    event?.flags = flags
    post(event)
    usleep(40_000)
}

/// Presses a key, by default with ⌥. The option key itself is pressed and released
/// (hotkeys check the real modifier state), and F-keys carry the fn flag like a real keyboard.
func press(_ key: Key, option: Bool = true) {
    let optionKey: CGKeyCode = 58
    var flags: CGEventFlags = option ? .maskAlternate : []
    if key != .escape { flags.insert(.maskSecondaryFn) }
    if option { keyEvent(optionKey, down: true, flags: .maskAlternate) }
    keyEvent(key.rawValue, down: true, flags: flags)
    keyEvent(key.rawValue, down: false, flags: flags)
    if option { keyEvent(optionKey, down: false, flags: []) }
}

var mouse = CGPoint.zero

/// Moves the pointer smoothly (ease in/out); with `dragging` it sends drag events.
func move(to target: CGPoint, duration: Double = 0.6, dragging: Bool = false) {
    let start = mouse
    let steps = max(1, Int(duration * 60))
    for i in 1...steps {
        let t = Double(i) / Double(steps)
        let e = t * t * (3 - 2 * t)
        let p = CGPoint(x: start.x + (target.x - start.x) * e, y: start.y + (target.y - start.y) * e)
        post(CGEvent(mouseEventSource: source, mouseType: dragging ? .leftMouseDragged : .mouseMoved,
                     mouseCursorPosition: p, mouseButton: .left))
        mouse = p
        usleep(useconds_t(1_000_000 / 60))
    }
}

func warp(to p: CGPoint) {
    CGWarpMouseCursorPosition(p)
    post(CGEvent(mouseEventSource: source, mouseType: .mouseMoved, mouseCursorPosition: p, mouseButton: .left))
    mouse = p
}

func click(right: Bool = false) {
    let (down, up, button): (CGEventType, CGEventType, CGMouseButton) =
        right ? (.rightMouseDown, .rightMouseUp, .right) : (.leftMouseDown, .leftMouseUp, .left)
    post(CGEvent(mouseEventSource: source, mouseType: down, mouseCursorPosition: mouse, mouseButton: button))
    usleep(70_000)
    post(CGEvent(mouseEventSource: source, mouseType: up, mouseCursorPosition: mouse, mouseButton: button))
}

func drag(from a: CGPoint, to b: CGPoint, duration: Double) {
    move(to: a, duration: 0.5)
    post(CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: a, mouseButton: .left))
    usleep(120_000)
    move(to: b, duration: duration, dragging: true)
    usleep(120_000)
    post(CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: b, mouseButton: .left))
}

func pause(_ seconds: Double) {
    usleep(useconds_t(seconds * 1_000_000))
}

// MARK: - Capture

/// Content rect of the demo window in global display coordinates (origin top left).
var captureRect = CGRect.zero

func rectArgument(_ r: CGRect) -> String {
    "\(Int(r.minX)),\(Int(r.minY)),\(Int(r.width)),\(Int(r.height))"
}

func screencapture(_ arguments: [String]) -> Process {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    p.arguments = arguments
    try! p.run()
    return p
}

func record(_ name: String, seconds: Int, actions: () -> Void) {
    print("recording \(name) (\(seconds) s)")
    let file = outputDir.appendingPathComponent("\(name).mov").path
    let p = screencapture(["-x", "-v", "-V\(seconds)", "-R\(rectArgument(captureRect))", file])
    pause(1.2)
    actions()
    p.waitUntilExit()
}

func still(_ name: String, rect: CGRect? = nil) {
    print("screenshot \(name)")
    let file = outputDir.appendingPathComponent("\(name).png").path
    screencapture(["-x", "-C", "-R\(rectArgument(rect ?? captureRect))", file]).waitUntilExit()
}

// MARK: - Demo page

final class Demo: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    var window: NSWindow!
    var web: WKWebView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let screen = NSScreen.screens[0]
        let frame = NSRect(x: screen.frame.midX - contentSize.width / 2,
                           y: screen.visibleFrame.maxY - contentSize.height - 60,
                           width: contentSize.width, height: contentSize.height)
        window = NSWindow(contentRect: frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.level = .floating
        web = WKWebView(frame: NSRect(origin: .zero, size: contentSize))
        web.navigationDelegate = self
        window.contentView = web
        web.loadFileURL(pageURL, allowingReadAccessTo: pageURL.deletingLastPathComponent())
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Quartz coordinates: origin at the top left of the main display.
        captureRect = CGRect(x: frame.minX, y: screen.frame.height - frame.maxY,
                             width: frame.width, height: frame.height)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            runScenario(self)
            DispatchQueue.main.async { NSApp.terminate(nil) }
        }
    }

    /// Screen rect of a page element, looked up by CSS selector.
    func element(_ selector: String) -> CGRect {
        var result = CGRect.zero
        let done = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            let js = "(() => { const r = document.querySelector('\(selector)').getBoundingClientRect();"
                + " return [r.x, r.y, r.width, r.height]; })()"
            self.web.evaluateJavaScript(js) { value, _ in
                if let v = value as? [Double], v.count == 4 {
                    result = CGRect(x: captureRect.minX + v[0], y: captureRect.minY + v[1], width: v[2], height: v[3])
                }
                done.signal()
            }
        }
        done.wait()
        precondition(result != .zero, "element not found: \(selector)")
        return result
    }
}

extension CGRect {
    var center: CGPoint { CGPoint(x: midX, y: midY) }
    func point(_ fx: Double, _ fy: Double) -> CGPoint { CGPoint(x: minX + width * fx, y: minY + height * fy) }
}

// MARK: - Scenario

func runScenario(_ demo: Demo) {
    let overview = demo.element("nav button:nth-child(1)")
    let regions = demo.element("nav button:nth-child(2)")
    let export = demo.element("nav button:nth-child(3)")
    let users = demo.element(".kpi:nth-child(2)")
    let conversion = demo.element(".kpi:nth-child(3)")
    let chart = demo.element(".grid .card:first-child")
    let table = demo.element(".grid .card:last-child")
    let home = captureRect.point(0.45, 0.55)

    // Click rings: left clicks on buttons, a right click on a KPI card.
    warp(to: home)
    record("clicks", seconds: 8) {
        move(to: overview.center, duration: 0.8); pause(0.3); click(); pause(0.6)
        move(to: regions.center); pause(0.3); click(); pause(0.6)
        move(to: users.point(0.5, 0.55), duration: 0.8); pause(0.3); click(right: true); pause(0.7)
        move(to: export.center, duration: 0.9); pause(0.3); click(); pause(0.8)
    }

    // Highlight: ⌥F1, drag around the chart, then click to dismiss.
    warp(to: home)
    record("highlight", seconds: 10) {
        move(to: chart.point(0.1, -0.05), duration: 0.6)
        press(.f1); pause(0.8)
        drag(from: chart.point(0, 0).applying(.init(translationX: -8, y: -8)),
             to: chart.point(1, 1).applying(.init(translationX: 8, y: 8)), duration: 1.4)
        move(to: chart.point(0.7, 0.6), duration: 0.6); pause(2.6)
        move(to: table.point(0.5, 0.5), duration: 0.8); pause(0.3); click(); pause(1.0)
    }

    // Spotlight: ⌥F2, wander over the page, ⌥F2 again.
    warp(to: conversion.center)
    record("spotlight", seconds: 9) {
        press(.f2); pause(0.8)
        move(to: users.center, duration: 0.9)
        move(to: chart.point(0.75, 0.45), duration: 1.2)
        move(to: table.point(0.4, 0.6), duration: 1.1)
        move(to: conversion.center, duration: 1.0); pause(0.6)
        press(.f2); pause(0.6)
    }

    // Halo: ⌥F3, move and click, ⌥F3 again.
    warp(to: home)
    record("halo", seconds: 8) {
        press(.f3); pause(0.6)
        move(to: chart.point(0.3, 0.4), duration: 0.9); pause(0.2); click(); pause(0.5)
        move(to: regions.center, duration: 1.0); pause(0.2); click(); pause(0.5)
        move(to: table.point(0.6, 0.5), duration: 1.0); pause(0.6)
        press(.f3); pause(0.5)
    }

    // Still: rectangle highlight with halo for the top of the README.
    warp(to: home)
    press(.f1); pause(0.5)
    drag(from: chart.point(0, 0).applying(.init(translationX: -8, y: -8)),
         to: chart.point(1, 1).applying(.init(translationX: 8, y: 8)), duration: 0.8)
    move(to: chart.point(0.82, 0.3), duration: 0.4); pause(0.6)
    still("hero")
    press(.f1); pause(0.4)

    // Still: the menu bar menu, cropped to the menu itself.
    if let item = statusItem(), let itemFrame = frame(of: item) {
        warp(to: itemFrame.center); pause(0.2); click(); pause(1.0)
        if let menu = openMenuFrame(of: item) {
            // Start just below the menu bar so other apps' status items stay out of the picture.
            still("menu", rect: CGRect(x: menu.minX - 14, y: menu.minY - 2,
                                       width: menu.width + 28, height: menu.height + 16))
        } else {
            print("menu not found")
        }
        press(.escape, option: false); pause(0.3)
    } else {
        print("status item not found")
    }
    warp(to: home)
}

// MARK: - Accessibility lookups (status item and its menu)

func attribute(_ element: AXUIElement, _ name: String) -> AnyObject? {
    var value: AnyObject?
    return AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success ? value : nil
}

func frame(of element: AXUIElement) -> CGRect? {
    guard let pos = attribute(element, kAXPositionAttribute), let size = attribute(element, kAXSizeAttribute)
    else { return nil }
    var point = CGPoint.zero, extent = CGSize.zero
    AXValueGetValue(pos as! AXValue, .cgPoint, &point)
    AXValueGetValue(size as! AXValue, .cgSize, &extent)
    return CGRect(origin: point, size: extent)
}

/// Followspot's status item in the menu bar.
func statusItem() -> AXUIElement? {
    guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.henpak.followspot").first
    else { return nil }
    let element = AXUIElementCreateApplication(app.processIdentifier)
    guard let bar = attribute(element, kAXExtrasMenuBarAttribute) else { return nil }
    return (attribute(bar as! AXUIElement, kAXChildrenAttribute) as? [AXUIElement])?.first
}

/// Frame of the menu that is open below the status item.
func openMenuFrame(of item: AXUIElement) -> CGRect? {
    let children = attribute(item, kAXChildrenAttribute) as? [AXUIElement] ?? []
    for child in children where (attribute(child, kAXRoleAttribute) as? String) == kAXMenuRole {
        return frame(of: child)
    }
    return nil
}

// MARK: - Main

guard AXIsProcessTrusted() else {
    print("error: the terminal needs Accessibility permission (System Settings → Privacy & Security → Accessibility)")
    exit(1)
}
guard CGPreflightScreenCaptureAccess() else {
    CGRequestScreenCaptureAccess()
    print("error: the terminal needs Screen Recording permission (System Settings → Privacy & Security → Screen & System Audio Recording)")
    exit(1)
}

let app = NSApplication.shared
let demo = Demo()
app.delegate = demo
app.setActivationPolicy(.accessory)
app.run()
