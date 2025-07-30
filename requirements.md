# Requirements Specification

## Project Overview
Flowmodachi is a macOS menubar productivity application that combines focus session tracking with a virtual pet evolution system to encourage healthy work habits and break-taking.

## Functional Requirements

### Core Features

#### F1: Flow Session Management
- **F1.1**: Start, pause, and reset focus session timers
- **F1.2**: Track elapsed time during active sessions
- **F1.3**: Persist session state across app restarts (configurable)
- **F1.4**: Minimum session threshold (5 minutes production, 5 seconds testing)
- **F1.5**: Record completed sessions to persistent storage

#### F2: Break Management
- **F2.1**: Suggest break duration based on session length
- **F2.2**: Configurable break calculation (default: 20% of session time, 5-20 min range, 30 min for 2+ hour sessions)
- **F2.3**: Break countdown timer with visual feedback
- **F2.4**: Break credit system for pet evolution
- **F2.5**: Audio notification when break ends (user configurable)
- **F2.6**: Customizable break duration parameters (multiplier, min/max limits)

#### F3: Pet Evolution System
- **F3.1**: Multi-stage character evolution (Egg → Form 1 → Form 2 → Form 3)
- **F3.2**: Evolution triggered by break completion
- **F3.3**: Dynamic character loading based on available assets
- **F3.4**: Rebirth system after reaching final evolution stage
- **F3.5**: Visual feedback during evolution transitions

#### F4: Session Analytics
- **F4.1**: Daily session tracking and statistics
- **F4.2**: Current streak calculation (consecutive active days)
- **F4.3**: Longest streak tracking
- **F4.4**: Total daily minutes calculation
- **F4.5**: Session history persistence

#### F5: Settings and Configuration
- **F5.1**: Toggle streak display visibility
- **F5.2**: Enable/disable sound notifications
- **F5.3**: Session goal configuration (15, 25, 45, 60 minutes)
- **F5.4**: Tutorial reset functionality
- **F5.5**: App reset to defaults
- **F5.6**: Feedback submission system
- **F5.7**: Testing mode toggle (enables reduced timers for development/testing)
- **F5.8**: Resume session on launch preference
- **F5.9**: Break duration customization (multiplier: 10-30%, min: 2-15 min, max: 15-30 min)

### User Interface Requirements

#### UI1: Menu Bar Integration
- **UI1.1**: Native macOS menu bar presence
- **UI1.2**: Menu bar icon with status indication
- **UI1.3**: Dropdown interface from menu bar
- **UI1.4**: No main application window (menu bar only)

#### UI2: Visual Design
- **UI2.1**: Consistent SwiftUI-based interface
- **UI2.2**: Character visualization with smooth animations
- **UI2.3**: Progress indicators for sessions and breaks
- **UI2.4**: Visual evolution effects and transitions
- **UI2.5**: Settings panel with standard macOS controls

#### UI3: Tutorial System
- **UI3.1**: ✅ Contextual onboarding with step-by-step guidance
- **UI3.2**: ✅ Progress indicators and navigation controls in tutorial
- **UI3.3**: ✅ Skip tutorial option for experienced users
- **UI3.4**: ✅ Tutorial reset functionality in settings
- **UI3.5**: ✅ Visual highlighting of tutorial target areas

#### UI4: Error Handling & Loading States
- **UI4.1**: ✅ Comprehensive error alert system with recovery suggestions
- **UI4.2**: ✅ Inline error displays for non-critical issues
- **UI4.3**: ✅ Loading state indicators with smooth transitions
- **UI4.4**: ✅ Success feedback for user actions
- **UI4.5**: ✅ Graceful degradation for missing assets or system failures

## Non-Functional Requirements

### Performance
- **P1**: Session timer accuracy within 1 second
- **P2**: UI responsiveness during state transitions
- **P3**: Minimal memory footprint for menu bar app
- **P4**: Fast app launch and session restoration

### Reliability
- **R1**: ✅ Session data persistence across app crashes
- **R2**: ✅ Graceful handling of missing character assets (implemented with fallback system)
- **R3**: ✅ Robust UserDefaults data management (enhanced with validation and cleanup)
- **R4**: ✅ Error handling for timer and persistence operations (comprehensive error recovery)

### Compatibility
- **C1**: macOS 14.0+ primary support
- **C2**: Multi-platform capability (iOS 18.4+, visionOS 2.4+)
- **C3**: Xcode 16.3+ build requirement
- **C4**: Swift 5.0 language compatibility

### Security and Privacy
- **S1**: Local data storage only (no network communication)
- **S2**: User consent for email feedback functionality
- **S3**: No sensitive data collection or transmission

## Testing Requirements

### Test Coverage
- **T1**: Unit tests for core business logic (FlowEngine, SessionManager)
- **T2**: UI automation tests for menu bar interactions
- **T3**: Testing mode for accelerated validation
- **T4**: Debug demo mode for development testing

### Test Scenarios
- **T5**: Session persistence across app restarts
- **T6**: Break calculation accuracy
- **T7**: Pet evolution state management
- **T8**: Settings persistence and restoration
- **T9**: ✅ Error handling for edge cases (comprehensive validation and recovery)
- **T10**: ✅ Tutorial system functionality and state management
- **T11**: ✅ Asset fallback system validation
- **T12**: ✅ Loading state and transition handling

## Development Requirements

### Build System
- **D1**: Xcode project configuration with proper targets
- **D2**: Asset catalog management for character images
- **D3**: Code signing and entitlements configuration
- **D4**: Multi-platform build support

### Code Quality
- **D5**: ✅ Swift best practices and conventions (with initialization safety patterns)
- **D6**: ✅ SwiftUI declarative UI patterns (with immutability constraint solutions)
- **D7**: ✅ Combine framework for reactive programming
- **D8**: ✅ Proper separation of concerns (MVVM-like architecture with global helpers)

## MVP Scope (Current Implementation)

The current MVP includes:
- ✅ Basic flow session tracking
- ✅ Break suggestion and management
- ✅ Pet evolution system with multiple forms
- ✅ Menu bar integration
- ✅ Session persistence
- ✅ Comprehensive settings panel with advanced configuration
- ✅ User-configurable testing mode
- ✅ Customizable break duration calculation
- ✅ Robust error handling and asset fallback systems
- ✅ Swift compilation compatibility with initialization safety patterns
- ✅ SwiftUI-compatible architecture with proper immutability handling
- ✅ Session goal picker interface
- ✅ Resume on launch preference
- ✅ Complete tutorial system with contextual guidance
- ✅ Enhanced loading states and visual feedback
- ✅ Comprehensive error handling with recovery options
- ✅ Accessibility improvements with proper labels and hints

## Future Enhancement Considerations

- Advanced analytics and reporting
- Cloud synchronization
- Additional pet types and evolution paths
- Integration with external productivity tools
- Custom break reminder notifications
- Dark mode optimization
- Multi-language localization