import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 🔧 Enable debug animation mode in development builds
        #if DEBUG
        UserDefaults.standard.set(true, forKey: "debugStreakAnimation")
        print("✅ Debug streak animation enabled")
        #endif

        // 🧩 Create and configure the status bar item (menu bar icon)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "face.dashed", accessibilityDescription: "Flowmodachi")
            button.image?.isTemplate = true // Ensures image adapts to light/dark mode
        }

        // 🧠 Attach the SwiftUI view to the menu bar popover
        popover = NSPopover()
        let contentView = MenuBarContentView()

        popover.contentSize = NSSize(width: 280, height: 360)
        popover.behavior = .transient // Closes when user clicks outside
        popover.contentViewController = NSHostingController(rootView: contentView)

        // 📎 Link the popover to the status item
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }


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
}

