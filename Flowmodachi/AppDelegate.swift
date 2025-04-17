import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    // MARK: - Shared Environment Objects
    private let petManager = PetManager()
    private let sessionManager = SessionManager()
    private let evolutionTracker = EvolutionTracker()
    private lazy var flowEngine = FlowEngine(
        sessionManager: sessionManager,
        evolutionTracker: evolutionTracker,
        petManager: petManager
    )

    // MARK: - App Launch
    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: ["resumeOnLaunch": true])

        #if DEBUG
        UserDefaults.standard.set(true, forKey: "debugStreakAnimation")
        print("✅ Debug streak animation enabled")
        #endif

        setupStatusItem()
        setupPopover()
    }

    // MARK: - Menu Bar Setup
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "face.dashed", accessibilityDescription: "Flowmodachi")
            button.image?.isTemplate = true
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 360)
        popover.behavior = .transient

        let contentView = MenuBarContentView()
            .environmentObject(flowEngine)
            .environmentObject(sessionManager)
            .environmentObject(evolutionTracker)
            .environmentObject(petManager)

        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    // MARK: - Click Handling
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        event?.type == .rightMouseUp ? showRightClickMenu() : togglePopover(sender)
    }

    @objc func handleRightClick() {
        showRightClickMenu()
    }

    private func showRightClickMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Flowmodachi", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu

        if let button = statusItem.button {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 4), in: button)
            statusItem.menu = nil // Reset menu to restore left-click behavior
        }
    }

    // MARK: - Actions
    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.becomeKey()
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    @objc private func openSettings() {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 180),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        settingsWindow.center()
        settingsWindow.title = "Settings"
        settingsWindow.isReleasedWhenClosed = false
        settingsWindow.contentView = NSHostingView(rootView: SettingsView())
        settingsWindow.makeKeyAndOrderFront(nil)
    }
}
