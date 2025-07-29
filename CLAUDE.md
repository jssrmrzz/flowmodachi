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

### Platform Support

Built for macOS with multi-platform support configured:
- Primary target: macOS 14.0+
- Secondary support: iOS 18.4+, iPadOS, visionOS 2.4+
- Swift 5.0, Xcode 16.3+