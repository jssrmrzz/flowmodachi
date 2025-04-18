import SwiftUI

// MARK: - View Extension

extension View {
    /// Attaches session lifecycle tracking (flow & break) and scene phase handling to any view.
    func trackSessionLifecycleChanges(using flowEngine: FlowEngine) -> some View {
        self
            .onChange(of: flowEngine.elapsedSeconds) {
                flowEngine.recordSessionIfEligible()
            }
            .onChange(of: flowEngine.isFlowing) { _, newValue in
                flowEngine.handleFlowPersistence(isFlowing: newValue)
            }
            .onChange(of: flowEngine.isOnBreak) { _, newValue in
                flowEngine.handleBreakPersistence(isOnBreak: newValue)
            }
            .modifier(ScenePhasePersistenceModifier(flowEngine: flowEngine)) // ✅ fixed parameter name
    }
}

// MARK: - Scene Phase Modifier

private struct ScenePhasePersistenceModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let flowEngine: FlowEngine

    func body(content: Content) -> some View {
        content
            .task(id: scenePhase) { // ✅ modern and safe in macOS 14+
                switch scenePhase {
                case .background:
                    flowEngine.handleFlowPersistence(isFlowing: flowEngine.isFlowing)
                    flowEngine.handleBreakPersistence(isOnBreak: flowEngine.isOnBreak)
                case .active:
                    flowEngine.restoreSessionIfAvailable()
                default:
                    break
                }
            }
    }
}
