import Cocoa
import SwiftUI

// MARK: - Custom Hosting Controller for Key Handling
class KeyHandlingHostingController<RootView: View>: NSHostingController<RootView> {
    private weak var flowEngine: FlowEngine?
    
    init(rootView: RootView, flowEngine: FlowEngine) {
        self.flowEngine = flowEngine
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 49: // Space bar
            handleSpacebarPress()
        case 53: // Escape key
            handleEscapePress()
        default:
            super.keyDown(with: event)
        }
    }
    
    private func handleSpacebarPress() {
        guard let flowEngine = flowEngine else { return }
        
        if flowEngine.isOnBreak {
            return // Space doesn't do anything during break
        }
        
        if flowEngine.isFlowing {
            flowEngine.pauseFlowTimer()
        } else {
            flowEngine.startFlowTimer()
        }
    }
    
    private func handleEscapePress() {
        view.window?.orderOut(nil)
    }
}

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
        setupKeyboardShortcuts()
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
        popover.contentSize = NSSize(width: 280, height: 420)
        popover.behavior = .transient

        let contentView = MenuBarContentView()
            .environmentObject(flowEngine)
            .environmentObject(sessionManager)
            .environmentObject(evolutionTracker)
            .environmentObject(petManager)

        popover.contentViewController = KeyHandlingHostingController(rootView: contentView, flowEngine: flowEngine)
    }
    
    private func setupKeyboardShortcuts() {
        // Global shortcut for start/pause flow
        let startPauseShortcut = NSMenuItem()
        startPauseShortcut.title = "Toggle Flow Session"
        startPauseShortcut.keyEquivalent = "f"
        startPauseShortcut.keyEquivalentModifierMask = [.command, .shift]
        startPauseShortcut.target = self
        startPauseShortcut.action = #selector(toggleFlowSession)
        
        // Create application menu to hold shortcuts
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        
        appMenu.addItem(startPauseShortcut)
        appMenu.addItem(.separator())
        appMenu.addItem(NSMenuItem(title: "Quit Flowmodachi", action: #selector(quitApp), keyEquivalent: "q"))
        
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
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
    
    @objc private func toggleFlowSession() {
        if flowEngine.isFlowing {
            flowEngine.pauseFlowTimer()
        } else if !flowEngine.isOnBreak {
            flowEngine.startFlowTimer()
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
