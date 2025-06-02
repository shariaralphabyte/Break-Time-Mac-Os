# BreakReminder 🧘‍♀️

A simple, elegant macOS menu bar application that reminds you to take regular breaks during your work day. Built with SwiftUI and designed to be lightweight and unobtrusive.
<img width="344" alt="Screenshot 2025-06-02 at 12 27 20 pm" src="https://github.com/user-attachments/assets/a25f11b2-dfea-4174-913d-03ccdba41edf" />



## 📱 Features

- **🔔 Smart Notifications**: Get gentle reminders when it's time to take a break
- **⏰ Customizable Intervals**: Set break reminders from 1 minute to several hours
- **🎯 Menu Bar Integration**: Lives quietly in your status bar - no dock clutter
- **🚀 Auto-Start**: Automatically launches when you log in to your Mac
- **🎨 Native Design**: Built with SwiftUI for a clean, modern macOS experience
- **⚡ Lightweight**: Minimal system resource usage
- **🔧 Fallback Alerts**: Works even if notifications are disabled

## 🖼️ Screenshots

*Menu Bar Icon*: A subtle clock icon appears in your status bar

*Settings Panel*: Clean, simple interface for configuring break intervals

*Break Notification*: Friendly reminder to take a break with customizable timing

## 🚀 Installation

### Option 1: Build from Source

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/BreakReminder.git
   cd BreakReminder
   ```

2. **Open in Xcode**
   ```bash
   open breakTime.xcodeproj
   ```

3. **Build and Run**
   - Press `⌘+R` to build and run
   - Grant notification permissions when prompted
   - The app will appear in your menu bar

### Option 2: Download Release

1. Download the latest release from the [Releases page](https://github.com/yourusername/BreakReminder/releases)
2. Move `BreakReminder.app` to your `Applications` folder
3. Right-click the app and select "Open" (first time only)
4. Grant notification permissions

## 📋 Requirements

- **macOS**: 11.0 (Big Sur) or later
- **Architecture**: Universal (Intel & Apple Silicon)
- **Permissions**: Notification access (optional but recommended)

## 🎯 Usage

### Basic Setup

1. **Launch the App**: BreakReminder will appear as a clock icon in your menu bar
2. **Configure Settings**: Click the menu bar icon to open settings
3. **Set Interval**: Choose your preferred break interval (default: 20 minutes)
4. **Start Timer**: Click "Start" to begin receiving break reminders

### Settings

| Setting | Description | Default |
|---------|-------------|---------|
| **Break Interval** | Time between break reminders | 20 minutes |
| **Auto-Start** | Launch automatically at login | Disabled |
| **Notifications** | System notification permissions | Required |

### Controls

- **Start/Pause**: Begin or pause the break timer
- **Reset**: Reset the timer to the full interval
- **Test**: Send a test notification to verify settings
- **Update**: Apply new interval settings

## 🔧 Auto-Start Setup

### Automatic Method
1. Click the menu bar icon
2. Click "Enable Auto-Start"
3. Follow any prompts that appear

### Manual Method
1. Open **System Settings** → **General** → **Login Items**
2. Click the **"+"** button
3. Navigate to and select **BreakReminder.app**
4. Ensure it's enabled in the list

### Alternative Method
1. Right-click **BreakReminder.app** in Applications
2. Select **Options** → **"Open at Login"**

## 🔔 Notification Setup

### First Time Setup
1. When you first run the app, macOS will ask for notification permission
2. Click **"Allow"** to enable break reminders
3. If you accidentally denied permission, see troubleshooting below

### Manual Permission Setup
1. Open **System Settings** → **Notifications**
2. Find **"breakTime"** or **"BreakReminder"** in the list
3. Enable **"Allow notifications"**
4. Set style to **"Alerts"** for best visibility

## 🛠️ Development

### Project Structure
```
BreakReminder/
├── breakTimeApp.swift          # Main app entry point
├── StatusBarController.swift   # Menu bar management
├── BreakTimer.swift           # Timer logic and persistence
├── ContentView.swift          # Settings UI
├── Assets.xcassets           # App icons and images
└── Info.plist               # App configuration
```

### Key Components

- **StatusBarController**: Manages the menu bar icon and popover interface
- **BreakTimer**: Handles timing logic, notifications, and settings persistence
- **ContentView**: SwiftUI interface for app settings and controls
- **AppDelegate**: Handles app lifecycle and permissions

### Building

1. **Clone and Setup**
   ```bash
   git clone https://github.com/yourusername/BreakReminder.git
   cd BreakReminder
   open breakTime.xcodeproj
   ```

2. **Configure Signing**
   - Select your development team in project settings
   - Update bundle identifier if needed

3. **Build**
   ```bash
   # Debug build
   xcodebuild -scheme breakTime -configuration Debug
   
   # Release build
   xcodebuild -scheme breakTime -configuration Release
   ```

## 🐛 Troubleshooting

### Notifications Not Working

**Problem**: "Notification permission denied" or no break reminders appearing

**Solutions**:
1. **Check System Settings**:
   - System Settings → Notifications → BreakReminder
   - Enable "Allow notifications"
   - Set to "Alerts" (not "None" or "Banners")

2. **Reset App Permissions**:
   ```bash
   tccutil reset Notifications com.yourcompany.breakTime
   ```
   Then restart the app and re-grant permissions

3. **Use Test Button**: Click "Test" in the app to verify notification setup

### Auto-Start Not Working

**Problem**: App doesn't launch automatically at login

**Solutions**:
1. **Try the manual method**: System Settings → General → Login Items
2. **Check app location**: Make sure the app is in `/Applications`
3. **Security settings**: Grant necessary permissions in System Settings

### App Not Appearing in Menu Bar

**Problem**: Can't find the app after launching

**Solutions**:
1. **Check menu bar**: Look for a clock icon in the right side of the menu bar
2. **Menu bar full**: Try expanding the menu bar or removing other items
3. **Restart app**: Quit and relaunch the application

### Build Errors

**Problem**: Swift compilation errors

**Solutions**:
1. **Clean build folder**: Product → Clean Build Folder (`⌘+Shift+K`)
2. **Check imports**: Ensure all files have required imports:
   - `import UserNotifications` in ContentView.swift and StatusBarController.swift
   - `import Foundation` in BreakTimer.swift
3. **Xcode version**: Ensure you're using Xcode 13.0 or later

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** and test thoroughly
4. **Commit your changes**: `git commit -m 'Add amazing feature'`
5. **Push to the branch**: `git push origin feature/amazing-feature`
6. **Open a Pull Request**

### Development Guidelines

- Follow Swift naming conventions
- Add comments for complex logic
- Test on multiple macOS versions if possible
- Update README.md for new features
- Ensure backward compatibility when possible

### Ideas for Contributions

- [ ] Custom notification sounds
- [ ] Multiple break types (short/long breaks)
- [ ] Break activity suggestions
- [ ] Usage statistics and analytics
- [ ] Focus mode integration
- [ ] Keyboard shortcuts
- [ ] Themes and customization
- [ ] Productivity insights

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 BreakReminder

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- Inspired by the need for healthier work habits
- Built with Apple's SwiftUI framework
- Icons from SF Symbols
- Thanks to the macOS development community

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/BreakReminder/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/BreakReminder/discussions)
- **Email**: your.email@example.com

---

**Made with ❤️ for healthier work habits**

*Remember: Taking regular breaks improves productivity, reduces eye strain, and promotes better health!*
