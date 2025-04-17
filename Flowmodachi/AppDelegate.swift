import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!

    // Shared environment objects
    private let sharedPetManager = PetManager()
    private let sharedSessionManager = SessionManager()
    private let sharedEvolutionTracker = EvolutionTracker()

    // MARK: - App Launch
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if DEBUG
        UserDefaults.standard.set(true, forKey: "debugStreakAnimation")
        print("✅ Debug streak animation enabled")
        #endif

        // 🧩 Create menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "face.dashed", accessibilityDescription: "Flowmodachi")
            button.image?.isTemplate = true
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
        }

        // 🪟 Set up popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 360)
        popover.behavior = .transient

        // 👇 Inject environment into root view
        let contentView = MenuBarContentView()
            .environmentObject(sharedSessionManager)
            .environmentObject(sharedEvolutionTracker)
            .environmentObject(sharedPetManager)

        popover.contentViewController = NSHostingController(rootView: contentView)
    }

    // MARK: - Status Bar Interactions
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            showRightClickMenu()
        } else {
            togglePopover(sender)
        }
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

        // Show the menu just above the icon
        if let button = statusItem.button {
            statusItem.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 4), in: button)
            statusItem.menu = nil // reset menu to allow normal left-click popover
        }
    }

    // MARK: - Actions
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    @objc func openSettings() {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 180),
            styleMask: [.titled, .closable, .miniaturizable],
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
