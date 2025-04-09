import SwiftUI

@main
struct FlowmodachiApp: App {
    // We’ll bridge SwiftUI with AppKit using this helper
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No UI scene (like WindowGroup) — this is menu bar only
        Settings {
            EmptyView()
        }
    }
}

