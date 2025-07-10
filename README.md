# GXEAdventure iOS App

A SwiftUI-based iOS application for location-based adventures and rewards.

## Prerequisites

Before you begin, ensure you have the following installed on your Mac:

### 1. Xcode
- **Required Version**: Xcode 14.0 or later
- **Download**: [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835)
- **Size**: ~7-10 GB (ensure you have enough disk space)
- **Installation Time**: 30-60 minutes depending on your internet connection

### 2. macOS Requirements
- macOS Ventura 13.0 or later (for latest Xcode)
- At least 10 GB of free disk space
- Apple ID (free to create at [appleid.apple.com](https://appleid.apple.com))

## Getting Started

### 1. Clone the Repository
```bash
git clone [your-repository-url]
cd GXEAdventure-iOS
```

### 2. Open the Project in Xcode
```bash
open GXEAdventure.xcodeproj
```
Or double-click the `GXEAdventure.xcodeproj` file in Finder.

### 3. First Time Xcode Setup
When you first open the project:

1. **Select a Development Team**:
   - Click on the project name in the navigator (top of the file list)
   - Select the "GXEAdventure" target
   - Go to "Signing & Capabilities" tab
   - Under "Team", select your Apple ID or development team

2. **Trust Developer Certificate** (if prompted):
   - Xcode may download and install additional components on first run
   - Accept any prompts for installing additional tools

### 4. Running the App

#### In the Simulator (Recommended for beginners)
1. Select a simulator device from the toolbar (e.g., "iPhone 15")
2. Press `Cmd + R` or click the "Play" button
3. Wait for the app to build and launch in the simulator

#### On a Physical Device
1. Connect your iPhone via USB cable
2. Select your device from the device list in the toolbar
3. Trust the computer on your iPhone when prompted
4. Press `Cmd + R` to build and run

**Note**: Running on a physical device requires:
- Apple Developer account (free or paid)
- Trusting the developer certificate on your iPhone:
  - Go to Settings → General → VPN & Device Management
  - Tap your developer profile and trust it

## Project Structure

```
GXEAdventure/
├── AdventureApp.swift      # Main app entry point
├── ContentView.swift       # Main content container
├── Views/
│   ├── SplashView.swift    # Initial loading screen
│   ├── OnboardingView.swift # First-time user experience
│   ├── LoadingView.swift   # Loading states
│   ├── ReadyView.swift     # Ready state screen
│   ├── RewardsTabView.swift # Rewards tab
│   ├── SettingsView.swift  # Settings screen
│   └── FeedbackView.swift  # User feedback
├── Managers/
│   ├── LocationManager.swift    # Handles GPS/location
│   └── NotificationManager.swift # Push notifications
├── Utilities/
│   ├── AppStyles.swift     # App-wide styling
│   └── SafariSwift.swift   # Web view helper
└── Assets.xcassets/        # Images and colors
```

## Key Features

- **Location Services**: The app uses GPS to provide location-based experiences
- **Push Notifications**: Alerts users about adventure drops and rewards
- **Onboarding Flow**: First-time user experience
- **Tab Navigation**: Multiple sections including rewards

## Common Tasks

### Adding a New View
1. Create a new Swift file: File → New → File → SwiftUI View
2. Import SwiftUI at the top
3. Create your view structure
4. Add navigation to it from an existing view

### Modifying App Colors/Styles
- Edit `AppStyles.swift` for consistent theming
- Colors are defined in `Assets.xcassets`

### Testing Location Features
- In the simulator: Debug → Location → Custom Location
- Set coordinates to test location-based features

## Debugging Tips

### Common Issues

1. **"No such module" errors**
   - Clean build folder: `Cmd + Shift + K`
   - Then rebuild: `Cmd + B`

2. **Simulator not showing up**
   - Xcode → Window → Devices and Simulators
   - Download additional simulators if needed

3. **App crashes on launch**
   - Check the console output (bottom of Xcode)
   - Look for red error messages

### Useful Xcode Shortcuts
- `Cmd + R` - Run the app
- `Cmd + .` - Stop the app
- `Cmd + Shift + O` - Quick open file
- `Cmd + 0` - Show/hide navigator
- `Cmd + Option + 0` - Show/hide inspector

## Resources for Swift Beginners

### Official Documentation
- [Swift Programming Language](https://docs.swift.org/swift-book/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)

### Recommended Learning Path
1. **Swift Basics**: Variables, functions, structs
2. **SwiftUI Fundamentals**: Views, State, Bindings
3. **iOS Concepts**: Navigation, data flow, lifecycle

### Video Tutorials
- [Apple's SwiftUI Tutorial](https://developer.apple.com/tutorials/app-dev-training)
- [Hacking with Swift](https://www.hackingwithswift.com/100/swiftui)

## Need Help?

### Project-Specific Questions
- Check existing code examples in the project
- Look for similar patterns in other views

### General iOS/Swift Questions
- [Stack Overflow](https://stackoverflow.com/questions/tagged/swiftui)
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Swift Forums](https://forums.swift.org)

## Next Steps

1. Run the app in the simulator to see it working
2. Explore the existing views to understand the structure
3. Try making small changes (like changing text or colors)
4. Build and run to see your changes

Remember: iOS development has a learning curve, but the Xcode error messages are usually helpful. Don't hesitate to search for error messages online - chances are someone else has encountered the same issue!