# Technology Stack

## Platform & Development Environment

### Core Platform
- **macOS**: Primary target platform (macOS 14.0+)
- **Multi-platform Support**: iOS 18.4+, iPadOS, visionOS 2.4+
- **Development Tools**: Xcode 16.3+
- **Language**: Swift 5.0
- **Minimum System**: macOS 14.0 (LSMinimumSystemVersion)

### Build System
- **Project Format**: Xcode project (.xcodeproj)
- **Target Architecture**: Universal (Intel + Apple Silicon)
- **Bundle Identifier**: com.jssrmrzz.Flowmodachi
- **Code Signing**: Automatic (development)

## Frameworks & Libraries

### UI Framework
- **SwiftUI**: Primary UI framework for declarative interface design
- **AppKit Integration**: NSApplicationDelegateAdaptor for menu bar functionality
- **Combine**: Reactive programming for state management

### System Integration
- **Foundation**: Core system services and data types
- **AVFoundation**: Audio playback for notifications
- **UserDefaults**: Local data persistence
- **NSWorkspace**: System interaction (email client launching)
- **NSSound**: System sound playback
- **NSPasteboard**: Clipboard operations

### Menu Bar Specific
- **NSStatusBar**: Menu bar item management
- **NSMenu**: Dropdown menu functionality
- **NSApplicationDelegateAdaptor**: SwiftUI-AppKit bridge

## Application Architecture

### Design Patterns
- **MVVM-inspired**: ObservableObject classes with Published properties
- **Reactive Programming**: Combine publishers for state updates
- **Dependency Injection**: Constructor-based dependency passing
- **Observer Pattern**: SwiftUI's automatic UI updates via @Published

### State Management
- **@ObservableObject**: Core business logic classes (FlowEngine, SessionManager, PetManager)
- **@Published**: Reactive state properties
- **@AppStorage**: UserDefaults-backed settings with extensive configuration options
- **@State/@Binding**: Local component state

### Data Flow
```
User Input → View → ObservableObject → Business Logic → UserDefaults
                                    ↓
                              UI Updates via @Published
```

## Core Components

### Business Logic Layer
- **FlowEngine**: Timer management and session coordination
- **SessionManager**: Data persistence and analytics
- **PetManager**: Character evolution and asset management
- **EvolutionTracker**: Break credit system

### Data Persistence Layer
- **UserDefaults**: Primary storage mechanism
- **SessionPersistenceHelper**: Session state management
- **BreakPersistenceHelper**: Break state management
- **JSON Encoding/Decoding**: Structured data serialization

### UI Layer
- **SwiftUI Views**: Declarative UI components
- **Asset Catalog**: Image and resource management
- **Custom Views**: Specialized components (ConfettiView, AuraRingView)

## Development Practices

### Code Organization
- **Single Responsibility**: Each class has a focused purpose
- **Modular Design**: Loosely coupled components
- **Testable Architecture**: Dependency injection for testing

### Testing Strategy
- **Unit Tests**: FlowmodachiTests target for business logic
- **UI Tests**: FlowmodachiUITests target for automation
- **Debug Modes**: Testing flags and demo data seeding

### Asset Management
- **Asset Catalog**: Centralized image and icon management
- **Dynamic Loading**: Runtime asset discovery for character system
- **Multi-resolution**: Automatic scaling for different displays

## Configuration & Settings

### Build Configuration
- **Debug/Release**: Standard Xcode build configurations
- **Code Signing**: Automatic development signing
- **Entitlements**: App sandbox and capabilities

### Runtime Configuration
- **isTestingMode**: User-togglable testing mode with reduced timers
- **playSounds**: Audio notification preference
- **breakMultiplier**: Configurable break duration calculation (10-30%)
- **minBreakMinutes**: Minimum break duration (2-15 minutes)
- **maxBreakMinutes**: Maximum break duration (15-30 minutes)
- **resumeOnLaunch**: Session restoration preference
- **sessionGoal**: Target session duration (15/25/45/60 minutes)

### Feature Flags
- **Testing Mode**: User-configurable reduced timers via @AppStorage
- **Debug Demo Mode**: Sample data generation (UserDefaults)
- **Debug Logging**: Conditional compilation directives

### User Preferences
- **AppStorage Backed**: SwiftUI property wrappers for comprehensive settings
- **Persistent Settings**: Automatic UserDefaults synchronization
- **Default Values**: Fallback configuration values
- **Break Configuration**: Customizable multiplier, minimum, and maximum break durations
- **Session Settings**: Goal configuration and resume-on-launch preferences
- **Audio Preferences**: Configurable sound notifications

## Performance Considerations

### Memory Management
- **ARC**: Automatic Reference Counting for memory management
- **Weak References**: Timer callbacks to prevent retain cycles
- **Asset Loading**: On-demand image loading

### Timer Implementation
- **NSTimer**: Foundation timer for session tracking
- **1-second Intervals**: Balance between accuracy and performance
- **Background Behavior**: Proper timer invalidation

### Data Storage
- **UserDefaults**: Lightweight for small datasets
- **JSON Serialization**: Efficient for structured data
- **Lazy Loading**: On-demand data restoration

## Security & Privacy

### Data Protection
- **Local Storage Only**: No network communication
- **App Sandbox**: Standard macOS security model
- **No Analytics**: Privacy-first approach

### Permission Model
- **Minimal Permissions**: Only necessary system access
- **User Consent**: Explicit permission for email functionality
- **Graceful Degradation**: Fallbacks when permissions denied

## Development Tools & Workflow

### Version Control
- **Git**: Source code management
- **GitHub**: Repository hosting and collaboration

### IDE & Tools
- **Xcode**: Primary development environment
- **Interface Builder**: SwiftUI previews and design
- **Simulator**: Multi-platform testing

### Debugging & Profiling
- **Xcode Debugger**: Runtime debugging
- **Instruments**: Performance profiling
- **Console Logging**: Debug output and diagnostics

## Future Technical Considerations

### Scalability
- **Core Data**: For more complex data relationships
- **CloudKit**: For cross-device synchronization
- **App Store Connect**: For distribution and analytics

### Advanced Features
- **Notifications**: Local and push notification support
- **Background Processing**: For timer continuation
- **Accessibility**: VoiceOver and assistive technology support

### Platform Evolution
- **SwiftUI Updates**: Adopting new framework features
- **macOS Versions**: Supporting new system capabilities
- **Multi-platform Optimization**: Platform-specific enhancements