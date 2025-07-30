# Development TODO

## High Priority

### MVP Refinements
- [x] **Testing Mode Toggle**: Add UI control to enable/disable testing mode instead of hardcoded flag
- [x] **Session Goal Implementation**: Enable the commented session goal picker in SettingsView
- [x] **Resume on Launch Setting**: Add UI toggle for session restoration preference
- [x] **Break Duration Customization**: Allow users to customize break calculation parameters
- [x] **Sound Management**: Implement playSounds setting throughout the app (currently only in settings)

### Bug Fixes & Polish
- [x] **Missing Asset Handling**: Improve error handling when character images are missing
- [x] **Timer Accuracy**: Validate timer precision and handle edge cases
- [x] **Memory Management**: Review timer cleanup and object lifecycle management
- [x] **State Synchronization**: Ensure UI state consistency across all components
- [x] **Settings Persistence**: Fix any settings that don't properly persist across launches

### User Experience
- [x] **Tutorial System**: Implement the tutorial that can be reset from settings
- [x] **Visual Feedback**: Add loading states and transition animations
- [x] **Accessibility**: Add VoiceOver support and accessibility labels
- [ ] **Keyboard Shortcuts**: Add menu bar keyboard shortcuts for common actions
- [x] **Error Messages**: Improve user-facing error messages and recovery options

## Medium Priority

### Features
- [ ] **Advanced Statistics**: Weekly/monthly statistics beyond current streak tracking
- [ ] **Export Data**: Allow users to export their session history
- [ ] **Custom Pet Names**: Let users name their virtual pets
- [ ] **Achievement System**: Add achievements for consistent usage
- [ ] **Focus Modes**: Different timer presets (Pomodoro, Deep Work, etc.)

### Technical Improvements
- [ ] **Unit Test Coverage**: Increase test coverage for core business logic
- [ ] **UI Testing**: Expand UI automation test suite
- [x] **Performance Optimization**: Profile and optimize memory usage and CPU impact
- [x] **Code Organization**: Refactor large files and improve code structure
- [ ] **Documentation**: Add inline documentation for complex algorithms

### Platform Support
- [ ] **iOS Compatibility**: Test and refine iOS version functionality
- [ ] **visionOS Support**: Optimize interface for visionOS platform
- [ ] **Universal App**: Ensure consistent experience across all supported platforms

## Low Priority

### Advanced Features
- [ ] **Cloud Sync**: Synchronize data across devices
- [ ] **Multiple Pets**: Support for multiple concurrent pets
- [ ] **Pet Customization**: Color variants and accessories for pets
- [ ] **Social Features**: Share achievements or compete with friends
- [ ] **Integration APIs**: Connect with other productivity apps

### Quality of Life
- [ ] **Dark Mode**: Ensure proper dark mode support throughout the app
- [ ] **Localization**: Add support for multiple languages
- [ ] **Advanced Settings**: More granular control over app behavior
- [ ] **Backup/Restore**: Manual backup and restore functionality
- [ ] **Beta Testing**: Set up TestFlight for beta user feedback

## Technical Debt

### Code Quality
- [x] **Error Handling**: Comprehensive error handling throughout the codebase
- [x] **Logging**: Implement proper logging system for debugging
- [x] **Constants Management**: Centralize magic numbers and configuration
- [x] **Dependency Injection**: Improve testability with better dependency management
- [x] **SwiftUI Best Practices**: Review and update to latest SwiftUI patterns

### Architecture
- [ ] **State Management**: Consider more sophisticated state management (e.g., TCA)
- [ ] **Data Layer**: Abstract data persistence layer for easier testing
- [ ] **Business Logic**: Extract business rules into dedicated classes
- [ ] **View Models**: Consider MVVM pattern for complex views
- [ ] **Networking Layer**: Prepare architecture for future network features

## Bug Reports & Issues

### Known Issues
- [ ] **Timer Drift**: Investigate potential timer drift over long sessions
- [ ] **Break Persistence**: Verify break state restoration works correctly
- [ ] **Asset Loading**: Handle dynamic asset loading failures gracefully
- [ ] **Settings Race Conditions**: Check for race conditions in settings updates
- [ ] **Memory Leaks**: Profile for potential memory leaks in timer operations

### User Feedback
- [ ] **Email Integration**: Improve email client detection and fallback handling
- [ ] **Feedback Collection**: Implement in-app feedback collection system
- [ ] **Crash Reporting**: Add crash reporting for better debugging
- [ ] **Analytics**: Consider privacy-friendly analytics for usage patterns

## Release Preparation

### MVP Release
- [ ] **Code Signing**: Set up proper code signing for distribution
- [ ] **App Store Preparation**: Prepare App Store listing and screenshots
- [ ] **Beta Testing**: Conduct thorough beta testing with target users
- [ ] **Documentation**: Create user documentation and help resources
- [ ] **Marketing Assets**: Create promotional materials and app preview

### Post-MVP
- [ ] **Update Mechanism**: Implement in-app update notifications
- [ ] **Versioning Strategy**: Establish versioning and release cadence
- [ ] **Feedback Loop**: Set up systems for collecting and acting on user feedback
- [ ] **Maintenance Plan**: Establish plan for ongoing maintenance and updates

---

## Development Challenges Resolved ⚡️

### Swift Compilation & SwiftUI Constraints
During implementation of Bug Fixes & Polish, several Swift language constraints were encountered and resolved:

#### **Challenge 1: SwiftUI View Mutability**
- **Issue**: Computed properties with custom setters cannot be mutated in SwiftUI Views (immutable structs)
- **Attempted Solutions**: Custom Binding closures, mutating methods
- **Final Solution**: Direct `@AppStorage` bindings with validation moved to consumption layer

#### **Challenge 2: Swift Initialization Order**
- **Issue**: Cannot call instance methods (even static ones with `Self.methodName`) before all stored properties are initialized
- **Attempted Solutions**: Static methods within class, `Self.` syntax
- **Final Solution**: Global helper functions outside class scope (`assetExists`, `createFallbackCharacter`)

#### **Challenge 3: Settings Validation Architecture**
- **Issue**: Balancing input validation with SwiftUI's reactive patterns
- **Resolution**: Validation at FlowEngine consumption layer, direct UserDefaults for reset functionality

#### **Lessons Learned**
- Swift's initialization safety is stricter than anticipated for complex constructors
- SwiftUI's immutability constraints require careful architectural planning
- Global functions provide initialization-safe alternatives to static class methods
- Iterative problem-solving with progressively simpler approaches proved most effective

## Completed Items ✅
- ✅ Core flow session tracking
- ✅ Break suggestion and timer system
- ✅ Pet evolution with multiple stages
- ✅ Menu bar integration and UI
- ✅ Session persistence across app launches
- ✅ Comprehensive settings panel with advanced configuration
- ✅ User-configurable testing mode
- ✅ Asset-based character system
- ✅ Streak calculation and statistics
- ✅ UserDefaults-based data persistence
- ✅ Session goal picker interface
- ✅ Customizable break duration calculation (multiplier, min/max)
- ✅ Resume on launch preference setting
- ✅ Integrated sound management throughout app
- ✅ Missing asset handling with fallback character system and graceful error recovery
- ✅ Timer accuracy improvements with 0.1s precision and bounds validation
- ✅ Memory management with proper timer lifecycle and leak prevention
- ✅ State synchronization with consistency validation and UI sync mechanisms
- ✅ Settings persistence with input validation and improved error handling
- ✅ Compilation error fixes with global functions approach and SwiftUI compatibility solutions
- ✅ Tutorial system implementation with 7-step guided onboarding
- ✅ Comprehensive error handling system with recovery options
- ✅ Enhanced loading states and visual feedback system
- ✅ Accessibility improvements with proper labels and hints