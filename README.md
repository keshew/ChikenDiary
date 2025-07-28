# Chicken Diary 🐔

A delightful SwiftUI app for tracking your beloved chickens' daily activities, mood, and egg production.

## Features

### 🏠 Chicken Groups Management
- Create multiple chicken groups (flocks)
- Add individual chickens with names, colors, and breeds
- Organize your chickens into logical groups

### 📝 Daily Diary Entries
- Record daily observations about your chickens
- Track mood levels (Very Happy, Happy, Neutral, Sad, Very Sad)
- Count eggs collected each day
- Add optional notes and observations
- View scrollable list of past entries with filtering options

### 📊 Comprehensive Statistics
- Total eggs collected across all groups
- Average mood calculation
- Activity calendar showing days with entries
- Group performance comparison
- Visual statistics with beautiful cards and charts

### 💾 Data Persistence
- All data saved locally using UserDefaults
- Automatic data persistence between app launches
- No internet connection required

## Technical Details

### Architecture
- **SwiftUI** for modern, declarative UI
- **MVVM** pattern with ObservableObject for data management
- **UserDefaults** for local data storage
- **SF Symbols** for consistent iconography

### Data Models
- `Chicken`: Individual chicken with name, color, breed
- `ChickenGroup`: Collection of chickens
- `DiaryEntry`: Daily diary entry with mood, eggs, notes
- `Mood`: Enum for chicken mood tracking

### Key Components
- **ChickenDiaryManager**: Central data management class
- **TabView**: Three main sections (My Chickens, Diary, Statistics)
- **NavigationView**: Hierarchical navigation
- **Custom Calendar**: Interactive calendar showing activity

## Getting Started

1. Open the project in Xcode
2. Build and run on iOS simulator or device
3. Create your first chicken group
4. Add chickens to your group
5. Start recording daily diary entries
6. Explore statistics and insights

## UI/UX Features

### Playful Design
- Orange accent color theme
- Friendly, approachable interface
- Suitable for users of all ages
- Clear visual hierarchy

### Intuitive Navigation
- Tab-based navigation for main sections
- Contextual empty states with helpful guidance
- Swipe actions for quick deletion
- Modal sheets for data entry

### Visual Feedback
- Color-coded mood indicators
- Egg count visualization
- Calendar highlighting for active days
- Progress indicators and statistics

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
2. Open `chikenRoadProj.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

## Usage

### Creating Chicken Groups
1. Tap the "My Chickens" tab
2. Tap the "+" button
3. Enter a group name
4. Add chickens to the group
5. Save the group

### Adding Diary Entries
1. Navigate to a chicken group
2. Tap "Add Diary Entry"
3. Select mood, egg count, and add notes
4. Save the entry

### Viewing Statistics
1. Tap the "Statistics" tab
2. View overall statistics
3. Explore the activity calendar
4. Compare group performance

## Contributing

This is a personal project, but suggestions and improvements are welcome!

## License

This project is for educational and personal use.

---

Made with ❤️ for chicken lovers everywhere! 🐔🥚 