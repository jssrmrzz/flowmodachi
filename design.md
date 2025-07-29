# Design System & UI/UX Documentation

## Design Philosophy

Flowmodachi combines productivity with playful gamification through a virtual pet companion. The design emphasizes **simplicity**, **delightful interactions**, and **non-intrusive productivity** enhancement.

### Core Design Values
- **Minimalist Interface**: Clean, focused UI that doesn't distract from work
- **Emotional Connection**: Pet evolution creates personal investment in productivity habits
- **Gentle Gamification**: Rewards without pressure or anxiety
- **Native macOS Feel**: Respects platform conventions and user expectations

## Visual Identity

### Color Palette
- **Primary**: System accent color (user configurable)
- **Break State**: Blue tones (#007AFF family)
- **Warning/Miss**: Orange (#FF9500)
- **Success/Complete**: Green (#34C759)
- **Neutral**: System grays for secondary content
- **Aura Colors**: Rotating palette (purple, blue, teal, mint, yellow, pink)

### Typography
- **Headers**: System font, semibold weight
- **Body Text**: System font, regular weight
- **Metrics**: Monospaced font for timers and statistics
- **Captions**: Smaller system font for secondary information

### Iconography
- **System Icons**: SF Symbols for consistency with macOS
- **Custom Artwork**: Pixel-art style pet characters and eggs
- **Menu Bar Icon**: Subtle "🫥" emoji representing the app

## Layout & Spacing

### Menu Bar Dropdown
- **Width**: Fixed 280pt for consistent presentation
- **Padding**: 16pt margins for comfortable content spacing
- **Vertical Spacing**: 16pt between major sections, 8pt between related elements
- **Component Spacing**: 4pt for tight groupings, 6pt for related items

### Component Hierarchy
1. **Header** - App title and info button
2. **Tutorial/Status Banners** - Contextual information
3. **Statistics** - Optional session data display
4. **Advanced Settings** - Break duration and testing mode controls
5. **Streak Information** - User engagement metrics
6. **Session Metrics** - Current session data
7. **Pet Visual** - Central character display
8. **Session Controls** - Primary interaction buttons
9. **Rebirth Controls** - Pet management actions

## Interactive Elements

### Buttons
- **Primary Actions**: `.borderedProminent` style for main actions
- **Secondary Actions**: `.plain` style for utility functions
- **Destructive Actions**: Red accent with clear labeling
- **Icon Buttons**: Minimalist approach with SF Symbols

### Controls
- **Toggles**: Standard SwiftUI toggle switches for binary options
- **Pickers**: Segmented control style for session goals and break parameters
- **Progress Indicators**: Custom ring-based progress visualization
- **Multi-Level Pickers**: Hierarchical options for break duration settings

### Feedback Systems
- **Visual**: Color changes, scale animations, opacity transitions
- **Audio**: System sounds for break completion (configurable)
- **Haptic**: None (menu bar app limitation)

## Animation & Motion

### Character Animations
- **Idle States**: Subtle floating, wobbling, or bouncing based on evolution stage
- **Evolution Transitions**: Dramatic visual effects (flashes, shockwaves, light bursts)
- **Break State**: Gentle pulsing to indicate rest period
- **Final Stage**: Rotating aura with sparkle particles

### UI Transitions
- **View Changes**: `.opacity` and `.move(edge:)` transitions
- **State Updates**: Spring animations for natural feel
- **Confetti**: Celebratory particle system for major milestones
- **Progress**: Smooth interpolation for timer and progress indicators

### Animation Timing
- **Quick Feedback**: 0.2-0.3 seconds for immediate responses
- **Content Transitions**: 0.4-0.6 seconds for view changes
- **Evolution Effects**: 0.6-1.0 seconds for dramatic moments
- **Ambient Motion**: 2-4 second cycles for subtle life

## Pet Character System

### Visual Design
- **Art Style**: Pixel art aesthetic for charm and scalability
- **Color Scheme**: Vibrant but not overwhelming
- **Stage Progression**: Clear visual evolution from simple to complex
- **Asset Organization**: Systematic naming (egg_N, form_N_stage)

### Evolution Stages
1. **Egg Stage (0)**: Simple, rounded forms with subtle patterns (9 variants)
2. **Form 1**: Basic creature shapes with minimal detail (9 variants)
3. **Form 2**: Intermediate complexity with more defined features (9 variants)
4. **Form 3**: Final forms with maximum detail and personality (9 variants)

### Character Traits
- **Size**: Consistent sizing across all evolution stages
- **Personality**: Animation patterns suggest different character types
- **Visual Effects**: Stage 3 characters get special aura effects
- **Missing Asset Handling**: Graceful fallback with clear error indication using system icons

## User Experience Patterns

### First-Time Experience
- **Tutorial Banner**: Friendly introduction with clear next steps
- **Progressive Disclosure**: Features revealed as users engage
- **No Onboarding Screens**: Immediate value with contextual guidance

### Session Flow
1. **Start Session**: Single-tap initiation
2. **Visual Feedback**: Character responds to session state
3. **Break Suggestion**: Automatic recommendations based on session length
4. **Break Taking**: Visual progress indication during rest
5. **Evolution Rewards**: Celebration when pets evolve

### Settings & Configuration
- **Comprehensive Options**: Essential customization plus advanced break configuration
- **Smart Defaults**: Sensible settings that work for most users
- **Feedback Integration**: Easy access to developer communication

## Error States & Defensive UX

### Graceful Degradation Principles
- **Asset Failures**: System icons (questionmark.circle, exclamationmark.triangle) replace missing character artwork
- **Placeholder Character System**: Fully functional fallback characters maintain app functionality when assets are missing
- **Visual Consistency**: Fallback elements use system colors and maintain the same sizing as regular characters
- **No User Disruption**: Asset failures are handled silently with appropriate fallbacks

### Error Recovery Patterns
- **State Consistency**: App automatically detects and corrects impossible state combinations (e.g., both flowing and on break)
- **Timer Recovery**: Broken timer states automatically reset to safe defaults
- **Settings Validation**: Invalid configuration values automatically clamped to safe ranges
- **Data Integrity**: Corrupted persistence data automatically cleared and reset to defaults

### Defensive Design Features
- **Bounds Validation**: All numeric inputs (session times, break durations) validated within reasonable limits
- **Asset Validation**: Character system validates image existence using global helper functions
- **State Synchronization**: UI updates are coordinated to prevent inconsistent visual states
- **Memory Management**: Proper cleanup prevents resource leaks that could degrade performance

### Implementation Architecture Notes
- **Global Functions**: Asset validation moved outside class scope for initialization safety
- **SwiftUI Compatibility**: Settings use direct `@AppStorage` bindings without computed property wrappers
- **Fallback Character System**: System icons (questionmark.circle, exclamationmark.triangle) provide consistent visual feedback for missing assets
- **Direct UserDefaults**: Reset functionality uses `UserDefaults.standard.set()` for SwiftUI Button compatibility
- **Validation Layer Separation**: Input validation occurs at consumption (FlowEngine) rather than UI layer
- **Reset Options**: Clear path to restore defaults
- **Testing Mode**: Developer-friendly option for reduced timers
- **Break Customization**: Fine-grained control over break duration calculation

## Accessibility

### Visual Accessibility
- **System Color Support**: Respects user color preferences
- **Font Scaling**: Uses system fonts that scale with user settings
- **Contrast**: Ensures adequate contrast ratios for readability
- **Color Independence**: Information not solely conveyed through color

### Interaction Accessibility
- **VoiceOver**: Labels and hints for screen reader users (planned)
- **Keyboard Navigation**: Standard tab ordering for controls (planned)
- **Reduced Motion**: Respects system motion preferences (planned)

## Error States & Edge Cases

### Missing Assets
- **Fallback Display**: Clear indication of missing character art
- **Development Aid**: Console logging for debugging
- **User Communication**: Non-technical error presentation

### Data Corruption
- **Graceful Degradation**: App continues functioning with defaults
- **Recovery Options**: Reset functionality available in settings
- **Data Validation**: Checks for corrupt or invalid stored data

### System Integration Failures
- **Email Client**: Fallback to manual copying when automatic opening fails
- **Sound Playback**: Silent fallback when audio system unavailable
- **Timer Accuracy**: Robust handling of system sleep/wake cycles

## Performance Considerations

### Resource Management
- **Asset Loading**: On-demand image loading with caching
- **Timer Efficiency**: Balanced update frequency (1-second intervals)
- **Memory Usage**: Minimal footprint appropriate for background app
- **Battery Impact**: Efficient animations and minimal background processing

### Scalability
- **Character System**: Dynamic loading supports arbitrary number of pets
- **Data Storage**: Efficient UserDefaults usage for small datasets
- **Animation System**: Modular approach allows adding new effects

## Platform Integration

### macOS Conventions
- **Menu Bar Behavior**: Standard dropdown interaction patterns
- **System Integration**: Uses native APIs for email, sounds, clipboard
- **Visual Style**: Follows macOS design language and spacing
- **Dark Mode**: Automatic support through system colors (planned)

### Multi-Platform Considerations
- **SwiftUI Foundation**: Shared UI code across platforms
- **Platform-Specific Adaptations**: Menu bar vs. main window on different platforms
- **Asset Scaling**: Vector-based icons, appropriate image densities

## Future Design Considerations

### Enhancement Opportunities
- **Customization**: Pet naming, color variants, accessories
- **Social Features**: Sharing achievements, comparing progress
- **Advanced Analytics**: Detailed productivity insights and trends
- **Integration**: Connection with other productivity tools and services

### Technical Evolution
- **SwiftUI Updates**: Adoption of new framework capabilities
- **Asset Pipeline**: More sophisticated character creation workflow
- **Animation System**: Enhanced particle effects and transitions
- **Accessibility**: Full accessibility feature implementation

## Design System Components

### Reusable Elements
- **Progress Rings**: Circular progress indicators
- **Character Display**: Consistent pet presentation
- **Metric Cards**: Statistics and information display
- **Action Buttons**: Standardized interaction elements
- **Status Banners**: Contextual information presentation
- **Settings Groups**: Organized configuration sections with clear hierarchy
- **Parameter Selectors**: Consistent picker styling for numerical options

### Style Guidelines
- **Spacing**: 4pt grid system for consistent alignment
- **Corner Radius**: 8-10pt for cards and containers
- **Shadows**: Subtle depth with system-appropriate opacity
- **Borders**: Minimal use, prefer color and spacing for separation

This design system ensures consistent, delightful user experiences while maintaining the productivity focus that makes Flowmodachi effective as a work companion.