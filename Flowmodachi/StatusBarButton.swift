import Cocoa

class StatusBarButton: NSStatusBarButton {
    override func rightMouseUp(with event: NSEvent) {
        NSApp.sendAction(#selector(AppDelegate.handleRightClick), to: nil, from: self)
    }
}

