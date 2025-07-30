import SwiftUI

// MARK: - Error Types
enum FlowmodachiError: Error, LocalizedError {
    case timerStartFailed
    case sessionSaveFailed
    case petEvolutionFailed
    case settingsLoadFailed
    case assetLoadFailed(String)
    case invalidSessionData
    case breakTimerFailed
    case persistenceError
    
    var errorDescription: String? {
        switch self {
        case .timerStartFailed:
            return "Unable to start the focus timer"
        case .sessionSaveFailed:
            return "Failed to save your session"
        case .petEvolutionFailed:
            return "Pet evolution encountered an issue"
        case .settingsLoadFailed:
            return "Settings could not be loaded"
        case .assetLoadFailed(let assetName):
            return "Could not load asset: \(assetName)"
        case .invalidSessionData:
            return "Session data appears to be corrupted"
        case .breakTimerFailed:
            return "Break timer could not be started"
        case .persistenceError:
            return "Data could not be saved to disk"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .timerStartFailed:
            return "Try restarting the app or check if another timer is running"
        case .sessionSaveFailed:
            return "Your progress is safe in memory. Try restarting the app to resolve this"
        case .petEvolutionFailed:
            return "Your pet's progress is saved. Try taking a break to trigger evolution again"
        case .settingsLoadFailed:
            return "Default settings will be used. You can customize them in Settings"
        case .assetLoadFailed:
            return "A placeholder will be shown instead. This doesn't affect functionality"
        case .invalidSessionData:
            return "Reset your session data in Settings > Reset App to Defaults"
        case .breakTimerFailed:
            return "You can manually end the break or restart the app"
        case .persistenceError:
            return "Check available storage space and app permissions"
        }
    }
    
    var canRetry: Bool {
        switch self {
        case .timerStartFailed, .sessionSaveFailed, .breakTimerFailed, .persistenceError:
            return true
        case .petEvolutionFailed, .settingsLoadFailed, .assetLoadFailed, .invalidSessionData:
            return false
        }
    }
}

// MARK: - Error Handler
class ErrorHandler: ObservableObject {
    @Published var currentError: FlowmodachiError?
    @Published var isShowingError = false
    
    func handleError(_ error: FlowmodachiError) {
        DispatchQueue.main.async {
            self.currentError = error
            self.isShowingError = true
        }
        
        // Log error for debugging
        print("🚨 FlowmodachiError: \(error.localizedDescription)")
        if let recovery = error.recoverySuggestion {
            print("💡 Recovery suggestion: \(recovery)")
        }
    }
    
    func dismissError() {
        withAnimation {
            isShowingError = false
            currentError = nil
        }
    }
    
    func retry(action: @escaping () -> Void) {
        dismissError()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            action()
        }
    }
}

// MARK: - Error Alert View
struct ErrorAlertView: View {
    @ObservedObject var errorHandler: ErrorHandler
    let retryAction: (() -> Void)?
    
    init(errorHandler: ErrorHandler, retryAction: (() -> Void)? = nil) {
        self.errorHandler = errorHandler
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)
                .accessibilityHidden(true)
            
            // Error message
            VStack(spacing: 8) {
                Text("Oops! Something went wrong")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                if let error = errorHandler.currentError {
                    Text(error.localizedDescription)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    if let recovery = error.recoverySuggestion {
                        Text(recovery)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            
            // Action buttons
            HStack(spacing: 12) {
                Button("Dismiss") {
                    errorHandler.dismissError()
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Dismiss error")
                
                if let error = errorHandler.currentError,
                   error.canRetry,
                   let retryAction = retryAction {
                    Button("Try Again") {
                        errorHandler.retry(action: retryAction)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Retry action")
                    .accessibilityHint("Attempts to perform the action again")
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(radius: 20)
        )
        .frame(maxWidth: 280)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Inline Error View
struct InlineErrorView: View {
    let error: FlowmodachiError
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?
    
    init(error: FlowmodachiError, onDismiss: @escaping () -> Void, onRetry: (() -> Void)? = nil) {
        self.error = error
        self.onDismiss = onDismiss
        self.onRetry = onRetry
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.orange)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(error.localizedDescription)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if let recovery = error.recoverySuggestion {
                    Text(recovery)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if error.canRetry, let retryAction = onRetry {
                    Button("Retry") {
                        retryAction()
                    }
                    .font(.caption2)
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
                
                Button("×") {
                    onDismiss()
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityLabel("Dismiss error")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Error Boundary View Modifier
struct ErrorBoundary: ViewModifier {
    @StateObject private var errorHandler = ErrorHandler()
    let retryAction: (() -> Void)?
    
    init(retryAction: (() -> Void)? = nil) {
        self.retryAction = retryAction
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .environmentObject(errorHandler)
            
            if errorHandler.isShowingError {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        errorHandler.dismissError()
                    }
                
                ErrorAlertView(errorHandler: errorHandler, retryAction: retryAction)
                    .zIndex(1000)
            }
        }
    }
}

extension View {
    func errorBoundary(retryAction: (() -> Void)? = nil) -> some View {
        self.modifier(ErrorBoundary(retryAction: retryAction))
    }
}

// MARK: - Safe Operation Wrapper
func safeOperation<T>(
    operation: () throws -> T,
    errorHandler: ErrorHandler,
    errorType: FlowmodachiError,
    fallback: T? = nil
) -> T? {
    do {
        return try operation()
    } catch {
        errorHandler.handleError(errorType)
        return fallback
    }
}