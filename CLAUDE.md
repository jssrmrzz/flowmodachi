# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flowmodachi is a macOS menubar productivity app that combines focus sessions with a virtual pet evolution system. The app lives entirely in the menu bar and encourages users to take breaks by rewarding them with pet evolution progress.

## Commands

### Building and Running
- **Build**: Open `Flowmodachi.xcodeproj` in Xcode and use Cmd+B to build
- **Run**: Open `Flowmodachi.xcodeproj` in Xcode and use Cmd+R to run
- **Test**: Use Cmd+U in Xcode to run unit tests (`FlowmodachiTests`)
- **UI Tests**: Use Cmd+U in Xcode to run UI tests (`FlowmodachiUITests`)

Note: This project requires Xcode (not just command line tools) and cannot be built from command line using `xcodebuild` without a full Xcode installation.

### Targets
- `Flowmodachi`: Main app target
- `FlowmodachiTests`: Unit tests
- `FlowmodachiUITests`: UI automation tests

## Architecture

### Core Components

**FlowEngine (`Flowmodachi/FlowEngine.swift`)**: Central timer and state management
- Manages flow sessions and break timers
- Handles session persistence across app launches
- Contains testing mode flags for MVP builds
- Coordinates with SessionManager, EvolutionTracker, and PetManager

**SessionManager (`Flowmodachi/SessionManager.swift`)**: Session tracking and statistics
- Persists flow sessions to UserDefaults
- Calculates streaks and daily statistics
- Includes debug demo mode for testing

**AppDelegate (`Flowmodachi/AppDelegate.swift`)**: MenuBar management
- Creates and manages the menu bar presence
- Bridges SwiftUI with AppKit for menu bar functionality

**FlowmodachiApp (`Flowmodachi/FlowmodachiApp.swift`)**: SwiftUI App entry point
- Menu bar only app (no main window)
- Uses NSApplicationDelegateAdaptor for AppKit integration

### Key Features

**Pet Evolution System**: 
- `PetManager.swift`: Manages pet states and evolution logic
- `EvolutionTracker.swift`: Tracks break credits for evolution
- `CharacterImageView.swift`: Displays pet character with different evolution stages
- Asset catalog contains egg and form images for different evolution stages

**Session Management**:
- Session persistence survives app restarts (configurable via `resumeOnLaunch` setting)
- Minimum session thresholds (5 seconds in testing mode, 5 minutes normally)
- Break suggestions based on session duration

**UI Components**:
- `MenuBarContentView.swift`: Main menu bar interface
- `FlowmodachiVisualView.swift`: Pet visualization and animation
- `SessionControlsView.swift`: Start/pause/reset controls
- `BreakControlsView.swift`: Break management interface
- `SettingsView.swift`: App configuration

### Testing and Debug Features

The app includes several testing and debug features:
- Testing mode flag in FlowEngine reduces minimum times for faster testing
- Debug demo mode in SessionManager seeds sample data
- Various debug logging throughout the codebase

### Data Persistence

- Sessions stored in UserDefaults via `SessionPersistenceHelper.swift`
- Break state stored in UserDefaults via `BreakPersistenceHelper.swift`
- Settings and preferences use UserDefaults

### Reliability & Error Handling

The app includes comprehensive error handling and reliability features:

**Asset Fallback System**:
- `PetManager` validates asset existence during initialization
- Fallback character system with system icons for missing assets
- Graceful evolution with asset validation and automatic fallbacks
- `CharacterImageView` handles both regular images and placeholder system icons

**Timer Accuracy & Validation**:
- High-precision 0.1s timer intervals with Date-based accuracy calculations
- Comprehensive bounds checking (24-hour max sessions, 1-hour max breaks)
- Edge case handling for timer state transitions and restoration
- Validation of all time values to prevent negative or extreme values

**Memory Management**:
- Proper timer cleanup with deinit methods and destruction state tracking
- Weak reference patterns in timer closures to prevent retain cycles
- Memory leak prevention with proper timer invalidation
- Object lifecycle management with cleanup methods

**State Synchronization**:
- `validateState()` method detects and fixes inconsistencies automatically
- `synchronizeUI()` ensures @Published properties trigger proper UI updates
- State validation calls in all key methods (start, pause, reset, end)
- Defensive state checking to prevent impossible state combinations

**Settings Persistence**:
- Input validation with proper bounds for all settings values
- Enhanced persistence helpers with timestamp and data validation
- Automatic cleanup of invalid UserDefaults data
- Direct UserDefaults manipulation for reset functionality (SwiftUI compatibility)

### Development Challenges & Solutions

During the implementation of reliability features, several Swift and SwiftUI constraints were encountered and resolved:

**Swift Initialization Safety**:
- **Challenge**: Cannot call instance methods before all stored properties are initialized
- **Solution**: Moved `assetExists()` and `createFallbackCharacter()` to global helper functions
- **Location**: Global functions in `PetManager.swift` before class definition
- **Benefit**: Initialization-safe asset validation without `self` context issues

**SwiftUI View Immutability**:
- **Challenge**: Cannot use computed properties with setters or mutating methods in SwiftUI Views
- **Solution**: Direct `@AppStorage` bindings with validation moved to consumption layer
- **Implementation**: `SettingsView.swift` uses standard bindings, validation in `FlowEngine.swift`
- **Reset Logic**: Direct `UserDefaults.standard.set()` calls for settings reset

**Architecture Evolution**:
- **Iteration 1**: Computed properties with custom setters (failed - SwiftUI immutability)
- **Iteration 2**: Static methods within class (failed - initialization order)
- **Final Solution**: Global functions + direct UserDefaults + consumption-layer validation

### Platform Support

Built for macOS with multi-platform support configured:
- Primary target: macOS 14.0+
- Secondary support: iOS 18.4+, iPadOS, visionOS 2.4+
- Swift 5.0, Xcode 16.3+